import fs from "fs";

class NFTAttributeEditor {
    loadMetadata(file: string): any[] {
        return JSON.parse(fs.readFileSync(file, "utf8"));
    }

    addTrait(metadata: any[], trait: string, value: string | number): any[] {
        return metadata.map(item => ({
            ...item,
            attributes: [...item.attributes, { trait_type: trait, value }]
        }));
    }

    updateTrait(metadata: any[], trait: string, newValue: any): any[] {
        return metadata.map(item => ({
            ...item,
            attributes: item.attributes.map((attr: any) =>
                attr.trait_type === trait ? { ...attr, value: newValue } : attr
            )
        }));
    }

    save(file: string, data: any[]) {
        fs.writeFileSync(file, JSON.stringify(data, null, 2));
    }
}

export default NFTAttributeEditor;
