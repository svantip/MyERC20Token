# ISBT - **Izvješće o izradi i testiranju jednostavnog tokena na Ethereum testnoj mreži (Ganache)**

---

*Student: Svan Tipurić*

*Fakultet informatike i digitalnih tehnologija*

*Kolegij: Informacijska sigurnost i blockchain tehnologije*

GitHub projekta: [here](https://github.com/svantip/MyERC20Token)

---

# **1. Uvod**

Ovo izvješće prikazuje korake izrade i testiranja pametnog ugovora za jednostavan token (ERC20) korištenjem:

- **Solidity** za pisanje pametnog ugovora
- **Remix IDE** za inicijalnu izradu i testiranje
- **Ganache** (lokalna Ethereum mreža) za simulaciju blockchain okruženja
- **Visual Studio Code (VSCode)** za organizaciju koda i suradnju s Remix-om
- **Ethers.js** (u sklopu jednostavnog web sučelja) za dodatni bonus zadatak interakcije  s tokenom

U nastavku je detaljan pregled implementacije, objašnjenje funkcionalnosti te rezultati testiranja.

# **2. Opis zadatka**

Zadatak je bio stvoriti pametni ugovor koji implementira osnovne značajke jednog jednostavnog sustava tokena:

- Mogućnost određivanja ukupne količine tokena (totalSupply) prilikom implementacije
- Mogućnost prijenosa tokena s jedne adrese na drugu (transfer)
- Mogućnost provjere stanja (balansa) za određenu adresu (balanceOf)
- Osnovne informacije o tokenu: ime, simbol i broj decimala
- Mogućnost da **vlasnik** pametnog ugovora (onaj tko ga je deploy-ao) poveća (mint) i smanji (burn) ukupnu ponudu tokena

Kao bonus ****zadatak, bilo je potrebno stvoriti i **web sučelje** koje komunicira s pametnim ugovorom.

# **3. Razvojni okoliš**

## 3.1.	**Ganache**

Ganache omogućuje lokalno pokretanje privatnog Ethereum blockchaina. Instalirao sam Ganache i pokrenuo ga. Ganache automatski kreira nekoliko testnih računa (adresa) s inicijalnim saldom (npr. 100 ETH) na lokalnoj mreži.

## 3.2.	**Remix IDE**

Za brzi razvoj i testiranje koristio sam Remix IDE. Remix nudi:

- Online editor za Solidity
- Integrirano testiranje (console)
- Deploy na različite mreže (lokalna, testna, mainnet)

## 3.3.	**Visual Studio Code**

Koristio sam VSCode zbog mogućnosti pokretanja projekta na serveru te integraciju sa metamask ekstenzijom.

## 3.4.	**Metamask**

Povezao sam Metamask s lokalnom Ganache mrežom tako da sam unio RPC endpoint (npr. HTTP://127.0.0.1:7545) u Metamask i dodao testne račune iz Ganache-a.

## 3.5.	**Ethers.js**

Za bonus zadatak koristio sam ethers.js (umjesto web3.js) jer je jednostavniji za korištenje, a radi jednako dobro.

# **4. Implementacija pametnog ugovora**

## **4.1. Solidity kod**

U nastavku se nalazi cjeloviti kod pametnog ugovora nazvanog Token.sol.

Datoteka: ERC20.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Token {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) private balances;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply;
        balances[owner] = _initialSupply;
        emit Transfer(address(0), owner, _initialSupply);
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Neispravna ciljna adresa.");
        require(balances[msg.sender] >= amount, "Nedovoljno tokena za prijenos.");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function mint(uint256 amount) public {
        require(msg.sender == owner, "Samo vlasnik moze kreirati nove tokene.");
        require(amount > 0, "Iznos mora biti veci od 0.");
        balances[owner] += amount;
        totalSupply += amount;
        emit Transfer(address(0), owner, amount);
    }

    function burn(uint256 amount) public {
        require(msg.sender == owner, "Samo vlasnik moze unistiti tokene.");
        require(balances[owner] >= amount, "Nedovoljno tokena za unistavanje.");
        balances[owner] -= amount;
        totalSupply -= amount;
        emit Transfer(owner, address(0), amount);
    }
}
```

**Ključne točke implementacije:**

- **name**, **symbol** i **decimals**: osnovni podaci o tokenu.
- **totalSupply**: prati ukupnu količinu tokena.
- **balances**: mapping za pojedinačne adrese i njihove balanse.
- **owner**: vlasnik ugovora, postavlja se u konstruktoru na msg.sender.
- **mint**: samo vlasnik može kreirati nove tokene.
- **burn**: samo vlasnik može uništiti tokene iz vlastitog salda.
- **transfer**: svi korisnici mogu prenijeti svoje tokene na neku drugu adresu.

# **5. Testiranje pametnog ugovora**

## **5.1. Deploy na lokalnu mrežu (Ganache)**

1. Pokrenuo sam **Ganache** i dobio RPC server (npr. HTTP://127.0.0.1:7545) s 10 testnih računa.
2. U **Remix IDE** postavio **Environment** na opciju **“Web3 Provider”** i unio http://127.0.0.1:7545 te odabrao prvi račun iz Ganache-a (koji je postao owner).
3. U kartici **Deploy & Run Transactions**:
- Izabrao sam kompajlirani Token kontrakt.
- Postavio parametre konstruktora, npr.:
- _name = "MojToken"
- _symbol = "MTK"
- _decimals = 0 (Inače se koristi 18 decimala unutar ERC20 tokena ali koristio sam 0 zbog jednostavnosti testiranja)
- _initialSupply = 1000000 (što znači 1,000,000 tokena)
- Kliknuo **Deploy**.

## 5.2. Nakon deploya, Remix je prikazao adresu mojeg ugovora (npr. 0x...).

## **5.3. Provjera početnog stanja**

Odmah sam provjerio funkcije:

- owner() -> vratio je moju adresu.
- name() -> "MojToken"
- symbol() -> "MTK"
- decimals() -> 0
- totalSupply() -> 1000000
- balanceOf -> 0

Sve se poklapalo s očekivanim rezultatima.

## **5.4. Test funkcije mint**

1. Pokrenuo sam mint(1000) preko Remix konzole (dok sam bio prijavljen s **owner** računom).
2. totalSupply() -> postao je 1001000.
3. balanceOf -> 1001000.

## **5.5. Test funkcije burn**

1. Pokrenuo sam burn(500) s vlasničkog računa.
2. totalSupply() -> 1000500 (smanjio se za 500).
3. balanceOf(owner) -> 1000500.

## **5.6. Test funkcije transfer**

1. Uzeo sam drugu adresu iz Ganache-a, npr. 0xABC....
2. Iz vlasničkog računa pozvao transfer(0xABC..., 1000).
3. Provjerio balanceOf(0xABC...) -> 1000, a balanceOf(owner) -> 999500 (nakon burn, mint, i sad transfer).

# **6. Bonus zadatak: jednostavno web sučelje za interakciju sa ugovorom**

Kao bonus, izradio sam **HTML/JS** stranicu koja koristi ethers.js za interakciju s ugovorom. Glavne funkcionalnosti:

•	**Povezivanje s Metamask** (gumb “Poveži se s Walletom”)

•	**Dohvat osnovnih informacija o tokenu** (gumb “Prikaži informacije o tokenu”)

•	**Provjera balansa** za zadanu adresu

•	**Transfer** tokena s trenutnog (povezanog) računa na drugu adresu

•	**Dohvat vlasnika ugovora**

Kod izgleda ovako (skraćeno za potrebe izvješća):
```html
<!DOCTYPE html>
<html lang="hr">
  <head>
    <meta charset="UTF-8" />
    <title>Token Interakcija</title>
    <script src="https://cdn.jsdelivr.net/npm/ethers@5.7.2/dist/ethers.umd.min.js"></script>
  </head>
  <body style="font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f9">
    <div style="max-width: 800px; margin: auto; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);">
      <h1 style="text-align: center; color: #333">Token Interakcija</h1>
      <div style="margin-bottom: 20px; text-align: center">
        <button id="connectButton" style="padding: 10px 20px; font-size: 16px; cursor: pointer; background-color: #4caf50; color: white; border: none; border-radius: 4px;">Poveži se s Walletom</button>
        <p><strong>Trenutno povezano:</strong> <span id="currentAddress">Niste povezani</span></p>
      </div>
      <h2 style="color: #555">Token informacije</h2>
      <div style="margin-bottom: 20px">
        <button id="getInfoButton" style="padding: 8px 16px; font-size: 14px; cursor: pointer; background-color: #007bff; color: white; border: none; border-radius: 4px;">Prikaži informacije o tokenu</button>
        <ul style="list-style: none; padding: 0; margin-top: 10px">
          <li>Ime: <span id="tokenName">N/A</span></li>
          <li>Simbol: <span id="tokenSymbol">N/A</span></li>
          <li>Decimals: <span id="tokenDecimals">N/A</span></li>
          <li>Ukupno u opticaju: <span id="tokenTotalSupply">N/A</span></li>
        </ul>
      </div>
      <h2 style="color: #555">Provjeri balans</h2>
      <div style="margin-bottom: 20px">
        <label for="balanceAddress" style="display: block; margin-bottom: 5px">Adresa:</label>
        <input type="text" id="balanceAddress" placeholder="Unesite adresu" style="padding: 8px; width: calc(100% - 20px); border: 1px solid #ddd; border-radius: 4px; margin-bottom: 10px;" />
        <button id="checkBalanceButton" style="padding: 8px 16px; font-size: 14px; cursor: pointer; background-color: #007bff; color: white; border: none; border-radius: 4px;">Provjeri</button>
        <p>Balans: <span id="balanceResult">N/A</span></p>
      </div>
      <script>
        const abi = [ /* ABI podaci */ ];
        // Adresa deployanog ugovor
        const contractAddress = "0xfa48e01799ab8902a14D954a009Db7F715D88F7E";
        let provider;
        let signer;
        let contract;
        document.getElementById("connectButton").addEventListener("click", async () => {
          if (window.ethereum) {
            const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
            provider = new ethers.providers.Web3Provider(window.ethereum);
            signer = provider.getSigner();
            document.getElementById("currentAddress").textContent = accounts[0];
            contract = new ethers.Contract(contractAddress, abi, signer);
          } else {
            alert("Metamask nije pronađen!");
          }
        });
        document.getElementById("getInfoButton").addEventListener("click", async () => {
          const name = await contract.name();
          const symbol = await contract.symbol();
          const decimals = await contract.decimals();
          const totalSupply = await contract.totalSupply();
          document.getElementById("tokenName").textContent = name;
          document.getElementById("tokenSymbol").textContent = symbol;
          document.getElementById("tokenDecimals").textContent = decimals;
          document.getElementById("tokenTotalSupply").textContent = totalSupply.toString();
        });
        document.getElementById("checkBalanceButton").addEventListener("click", async () => {
          const address = document.getElementById("balanceAddress").value;
          const balance = await contract.balanceOf(address);
          document.getElementById("balanceResult").textContent = balance.toString();
        });
      </script>
    </div>
  </body>
</html>
```
![Token_Interakcija](https://github.com/user-attachments/assets/3418c88a-9bed-4c61-956f-9eb97266b2b0)

