const solc = require("solc");
const fs = require("fs");

class SolidityCompilerTool {
    compileContract(filePath, contractName) {
        const source = fs.readFileSync(filePath, "utf8");
        const input = {
            language: "Solidity",
            sources: { [filePath]: { content: source } },
            settings: { outputSelection: { "*": { "*": ["abi", "bytecode"] } } },
        };
        const output = JSON.parse(solc.compile(JSON.stringify(input)));
        if (output.errors) {
            for (const err of output.errors) console.error(err.formattedMessage);
        }
        const contract = output.contracts[filePath][contractName];
        return {
            abi: contract.abi,
            bytecode: contract.bytecode,
            success: !!contract.abi,
        };
    }

    saveCompiled(outputPath, data) {
        fs.writeFileSync(outputPath, JSON.stringify(data, null, 2));
        return true;
    }
}

module.exports = SolidityCompilerTool;
