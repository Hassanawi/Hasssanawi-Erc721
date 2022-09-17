require("dotenv").config();
const path = require("path");
const fs = require("fs");
const axios = require("axios");
const Formdata = require("form-data");
const pinataEndPoint = "";
const pinataAPI = "";
const pinataApiSecret = "";

const PinImageToIpfs = async (filePath, filename) => {
  const form_data = new Formdata();
  try {
    form_data.append("file", fs.createReadStream(`${filePath}//${filename}`));

    const request = {
      method: "post",
      url: pinataEndPoint,
      maxContentLength: "Infinity",
      headers: {
        pinata_api_key: pinataAPI,
        pinata_secret_api_key: pinataApiSecret,
        "Content-Type": `multipart/form-data; boundry=${form_data._boundry}`,
      },
      data: form_data,
    };
    const response = await axios(request);
    const imageHash = response.data.IpfsHash;
   // console.log(imageHash);
    let name = filename;
    const Name = name.slice(0, -4);

    metadata = {
      name: `${Name}`,
      description: "Friendly cartoon.",
      image: "https://gateway.pinata.cloud/ipfs/" + imageHash,
      attributes: [
        {
          "trait_type ": " Personality",
          value: "awsome",
        },
        {
          "trait_type ": "boost_number",
          value: "power",
        },
        {
          "trait_type ": " Network",
          value: "Rinkeby testnet",
        },
      ],
    };

    const metadataJson = JSON.stringify(metadata);
    await fs.writeFile(
      path.join(__dirname, `../metadata/${Name}.json`),
      metadataJson,
      "utf8",
      function (err) {
        if (err) {
          console.log(
            "An error has occured while writing Jason Object to file"
          );
          return console.log(err);
        } else {
          console.log(
            "Json files have been saved to the ",
            `/metadata/${Name}`
          );
        }
      }
    );

    const getMetadataJson = path.join(__dirname, `../metadata/${Name}.json`);

    const form_meta_data = new Formdata();
    try {
      form_meta_data.append("file", fs.createReadStream(getMetadataJson));

      const request = {
        method: "post",
        url: pinataEndPoint,
        maxContentLength: "Infinity",
        headers: {
          pinata_api_key: pinataAPI,
          pinata_secret_api_key: pinataApiSecret,
          "Content-Type": `multipart/form-data; boundry = ${form_meta_data._boundry}`,
        },
        data: form_meta_data,
      };
      const response = await axios(request);
      console.log(response.data.IpfsHash);
    } catch (err) {
      console.log(err);
    }
  } catch (err) {
    console.log(err);
  }
};
module.exports = { PinImageToIpfs };
