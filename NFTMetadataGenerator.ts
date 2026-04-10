import fs from "fs";

interface NFTAttribute {
    trait_type: string;
    value: string | number;
}

interface NFTMetadata {
    name: string;
    description: string;
    image: string;
    attributes: NFTAttribute[];
}

class NFTMetadataGenerator {
    generateMetadata(
        name: string,
        desc: string,
        image: string,
        attributes: NFTAttribute[]
    ): NFTMetadata {
        return { name, description: desc, image, attributes };
    }

    batchGenerate(count: number, baseName: string, imageBase: string): NFTMetadata[] {
        const list: NFTMetadata[] = [];
        for (let i = 1; i <= count; i++) {
            list.push({
                name: `${baseName} #${i}`,
                description: `Auto-generated NFT ${i}`,
                image: `${imageBase}/${i}.png`,
                attributes: [
                    { trait_type: "Series", value: baseName },
                    { trait_type: "Rarity", value: i % 5 === 0 ? "Legendary" : "Common" },
                ],
            });
        }
        return list;
    }

    saveToFile(path: string, data: NFTMetadata[]) {
        fs.writeFileSync(path, JSON.stringify(data, null, 2));
    }
}

export default NFTMetadataGenerator;
