default:
  forge build

watch:
  watchexec 'forge test -vv'

get-erc721-contract:
  cd src && wget https://raw.githubusercontent.com/Rari-Capital/solmate/main/src/tokens/ERC721.sol
