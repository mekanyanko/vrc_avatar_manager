// @ts-check

import fs from "fs";
import { type AppcastItem, createAppcastXml } from "./createAppcastXml.js";
const dirname = import.meta.dirname;

const url = process.env.URL;
const vVersion = process.env.VERSION;
const sig = process.env.SIG;
if (!sig || !vVersion || !url) {
  throw new Error("SIG, VERSION and URL is required");
}

const version = vVersion.replace(/^v/, "");

const sigMatched = sig.match(/sparkle:dsaSignature="(?<dsaSignature>[^"]+)" length="(?<length>[^"]+)"/);
if (!sigMatched) {
  throw new Error("Invalid SIG");
}
const { dsaSignature, length } = sigMatched.groups;

const item: AppcastItem = {
  version,
  url,
  pubDate: new Date(),
  os: "windows",
  length: Number(length),
  dsaSignature,
};

const previousUrl = "https://narazaka.github.io/vrc_avatar_manager/appcast.xml";
const previousResult = await fetch(previousUrl);
const previous = previousResult.ok ? await previousResult.text() : undefined;

const xml = createAppcastXml({ previous, setting: {
  title: "VRChat Avatar Manager",
  description: "Most recent updates to VRChat Avatar Manager",
  language: "en",
}, items: [item], mode: "add" });
console.log(xml);
fs.mkdirSync(`${dirname}/../dist`, { recursive: true });
fs.writeFileSync(`${dirname}/../dist/appcast.xml`, xml);
