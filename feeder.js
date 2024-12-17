const { ethers } = require("ethers");
const { transformForOnchain } = require("@reclaimprotocol/js-sdk");
const { ReclaimClient } = require("@reclaimprotocol/zk-fetch");
const dataFeedDAOABI = require("./DataFeedDAO.json");
const CONFIG = require("./config.json");
require("dotenv").config();

// Setting up configurations
const network = process.env.NETWORK;
const apiUrl = process.env.API_URL;
const appSecret = process.env.APP_SECRET;
const { rpcEndpoint, contractAddress, explorerLink } = CONFIG.networks[network];
const FEED_INTERVAL = process.env.FEED_INTERVAL;

// Setting up instances
const provider = new ethers.JsonRpcProvider(rpcEndpoint);
const wallet = new ethers.Wallet(appSecret, provider);
const contract = new ethers.Contract(
  contractAddress,
  dataFeedDAOABI.abi,
  wallet
);

// Setting up reclaim client
const reclaimClient = new ReclaimClient(wallet.address, appSecret);

// Function to fetch data from the URL
const fetchProof = async (url) => {
  const options = {
    method: "GET",
    headers: {
      accept: "application/json, text/plain, */*",
    },
  };
  return await reclaimClient.zkFetch(url, options);
};

const transformVerifiedResponse = (claim) => {
  return JSON.parse(
    claim.claimInfo.parameters
  ).responseMatches[0].value.replaceAll('"', '\\"');
};

const submitToContract = async (url, claim) => {
  console.log(claim);
  const transformedClaim = transformForOnchain(claim);

  let verifiedResponse = transformVerifiedResponse(transformedClaim);

  return await contract.submitData(url, verifiedResponse, transformedClaim);
};

const submitData = async (url) => {
  try {
    console.info("Submitting data...");
    const claim = await fetchProof(url);
    const result = await submitToContract(url, claim);
    result.wait().then(async () => {
      console.log("Submission was successful!");
      console.log(`Transaction link: ${explorerLink}tx/${result.hash}`);
      console.log(`Next submission is in ${FEED_INTERVAL * 1.05} seconds.\n`);
      setTimeout(() => submitData(url), FEED_INTERVAL * 1050);
    });
  } catch (error) {
    if (error.message.indexOf("Invalid receipt") !== -1) {
      console.error(error.message);
      console.log("Resubmitting...");
      submitData(url);
      return;
    } else {
      console.error("Error submitting data:", error.message);
      console.log(`Next submission is in ${FEED_INTERVAL * 1.05} seconds.\n`);
      setTimeout(() => submitData(url), FEED_INTERVAL * 1050);
    }
  }
};

submitData(apiUrl);
