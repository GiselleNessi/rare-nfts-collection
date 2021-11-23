// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  uint256 private _totalSupply = 30;

    // We split the SVG at the part where it asks for the background color.
  string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
  string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  string[] firstWords = ["Algarete", "Bebecita", "Bellaca", "Bichota", "Bellaca", "Cangri", "Chavos", "Combi", "Corillo", "Dura", "Fronteo", "Guayo", "Mera", "Perrear", "Pichar", "Piquete", "Tiraera", "Hanguiar", "Acicalao", "Bregar", "Brutal", "Nene", "Gata", "Perreo", "Chama", "Srifino", "Guasa", "Dembow", "Bellaco", "Bebe"];

/*   string[] firstWords = ["Whis", "Beerus", "Goten", "Chiaotzu", "Tien", "Roshi", "Master", "Piccolo", "Frieza", "Dodoria", "Nappa", "Cooler", "Cell", "Broly", "Goku", "Korin", "Naruto", "Itachi", "Vegeta", "Pikachu", "Trunks", "Charmander", "Charmeleon", "Charizard", "Squirtle", "Clefairy", "Jigglypuff", "Wigglytuff", "Meowth", "Psyduck", "Gengar", "Hypno", "Jynx", "Draganite", "Mewtwo", "Mew"];

  string[] secondWords = ["Ser", "Haber", "Estar", "Tener", "Hacer", "Poder", "Decir", "Ir", "Ver", "Dar", "Saber", "Querer", "Llegar", "Pasar", "Deber", "Poner", "Parecer", "Quedar", "Creer", "Hablar", "Llevar", "Dejar", "Seguir", "Encontrar", "Llamar", "Venir", "Pensar", "Volver" ];

  string[] thirdWords = ["Algarete", "Bebecita", "Bellaca", "Bichota", "Bicho", "Cangri", "Chavos", "Combi", "Corillo", "Dura", "Fronteo", "Guayo", "Mera", "Perrear", "Pichar", "Piquete", "Tiraera", "Hanguiar", "Acicalao", "Bregar", "Brutal", "Nene", "Gata", "Perreo", "Chama", "Srifino"]; */

  // Get fancy with it! Declare a bunch of colors.
  string[] colors = ["red", "#e30edc", "black", "yellow", "blue", "green"];

  event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract. Woah!");
  }

  function getTotalNFTsMintedCount () public view returns (uint) {
    return _tokenIds.current();
  }

  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // seed the random generator
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  /* function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  } */

   // Same old stuff, pick a random color.
  function pickRandomColor(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("COLOR", Strings.toString(tokenId))));
    rand = rand % colors.length;
    return colors[rand];
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

    require(_totalSupply > newItemId, "SOLD OUT: Theres a mint limit of 30");

    string memory first = pickRandomFirstWord(newItemId);
    //string memory second = pickRandomSecondWord(newItemId);
    //string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first/* , second, third */));

    // Add the random color in.
    string memory randomColor = pickRandomColor(newItemId);
    string memory finalSvg = string(abi.encodePacked(svgPartOne, randomColor, svgPartTwo, combinedWord, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares and perreo.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}




