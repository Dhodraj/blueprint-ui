#!/usr/bin/env node
// Validates sources.json: shape, required fields, unique ids, no duplicate
// urls, and no entry that is both listed and rejected. With --links it also
// asks each url for a response, which needs the network.
// Exit 0 clean, 1 a problem in the file, 2 the file could not be read.
"use strict";

const fs = require("fs");
const path = require("path");

const file = process.argv[2] || path.join(__dirname, "..", "sources.json");
const checkLinks = process.argv.includes("--links");

let data;
try {
  data = JSON.parse(fs.readFileSync(file, "utf8"));
} catch (error) {
  console.error(`cannot read ${file}: ${error.message}`);
  process.exit(2);
}

const problems = [];
const REQUIRED = ["id", "url", "for", "stack", "licence"];

if (data.version !== 1) problems.push(`version must be 1, found ${JSON.stringify(data.version)}`);
if (!/^\d{4}-\d{2}-\d{2}$/.test(data.updated || "")) problems.push("updated must be a YYYY-MM-DD date");

const seenId = new Map();
const seenUrl = new Map();

for (const list of ["components", "screens", "patterns"]) {
  // components and screens are required; patterns is optional.
  if (data[list] === undefined && list === "patterns") continue;
  if (!Array.isArray(data[list])) {
    problems.push(`${list} must be an array`);
    continue;
  }
  data[list].forEach((entry, index) => {
    const where = `${list}[${index}]`;
    for (const field of REQUIRED) {
      if (entry[field] === undefined || entry[field] === "") problems.push(`${where} has no ${field}`);
    }
    if (entry.for !== undefined && !Array.isArray(entry.for)) problems.push(`${where}.for must be an array`);
    if (Array.isArray(entry.for) && entry.for.length === 0) problems.push(`${where}.for is empty`);
    if (entry.url && !/^https?:\/\//.test(entry.url)) problems.push(`${where}.url is not a url`);
    if (entry.id) {
      if (seenId.has(entry.id)) problems.push(`${where}.id "${entry.id}" repeats ${seenId.get(entry.id)}`);
      else seenId.set(entry.id, where);
    }
    if (entry.url) {
      if (seenUrl.has(entry.url)) problems.push(`${where}.url repeats ${seenUrl.get(entry.url)}`);
      else seenUrl.set(entry.url, where);
    }
  });
}

if (!Array.isArray(data.rejected)) {
  problems.push("rejected must be an array");
} else {
  data.rejected.forEach((entry, index) => {
    const where = `rejected[${index}]`;
    if (!entry.url) problems.push(`${where} has no url`);
    if (!entry.reason) problems.push(`${where} has no reason`);
    if (entry.url && seenUrl.has(entry.url)) problems.push(`${where} is also listed at ${seenUrl.get(entry.url)}`);
  });
}

const report = (code) => {
  if (problems.length === 0) {
    const n = (data.components || []).length + (data.screens || []).length + (data.patterns || []).length;
    console.log(`sources.json: ${n} sources, ${(data.rejected || []).length} rejected, no problems`);
  } else {
    for (const problem of problems) console.error(problem);
  }
  process.exit(problems.length ? 1 : code);
};

if (!checkLinks) report(0);

(async () => {
  const urls = [...seenUrl.keys()];
  await Promise.all(urls.map(async (url) => {
    try {
      const response = await fetch(url, { method: "GET", redirect: "follow", signal: AbortSignal.timeout(15000) });
      if (!response.ok) problems.push(`${url} answered ${response.status}`);
    } catch (error) {
      problems.push(`${url} did not answer: ${error.message}`);
    }
  }));
  report(0);
})();
