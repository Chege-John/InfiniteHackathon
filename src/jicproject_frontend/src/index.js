import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory as jamboIdlFactory, canisterId as jamboCanisterId } from "your-canister.did.js";

// Create an agent to interact with the canister
const agent = new HttpAgent();
const jamboActor = Actor.createActor(jamboIdlFactory, { agent, canisterId: jamboCanisterId });

// Function to create a new Jambo
async function createJambo() {
  const title = document.getElementById("title").value;
  const description = document.getElementById("description").value;
  const image = document.getElementById("image").files[0];
  const duration = parseInt(document.getElementById("duration").value, 10);

  // Convert the image to a Blob
  const reader = new FileReader();
  reader.onload = async function () {
    const imageBlob = new Blob([new Uint8Array(reader.result)], { type: "image/*" });

    // Call the Motoko canister to create a new Jambo
    await jamboActor.newJambo({ title, description, image: imageBlob }, duration);

    // Refresh the Jambo list
    await refreshJamboList();
  };
  reader.readAsArrayBuffer(image);
}

// Function to refresh the list of Jambo overviews
async function refreshJamboList() {
  const jamboListElement = document.getElementById("jamboList");
  jamboListElement.innerHTML = "";

  // Call the Motoko canister to get the list of Jambo overviews
  const jamboOverviews = await jamboActor.getOverviewList();

  // Display each Jambo overview
  jamboOverviews.forEach((jamboOverview) => {
    const listItem = document.createElement("li");
    listItem.textContent = `${jamboOverview.id}: ${jamboOverview.item.title}`;
    jamboListElement.appendChild(listItem);
  });
}

// Initial page load: refresh the Jambo list
refreshJamboList();