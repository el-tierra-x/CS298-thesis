export const computeImageHash = async (
  uri: string,
  metadata: Record<string, any>
): Promise<string | null> => {
  try {
    const { exists } = await FileSystem.getInfoAsync(uri);
    if (!exists) throw new Error("File\ not\ found");

    const [base64Data, criticalFields] = await Promise.all([
      FileSystem.readAsStringAsync(uri, {
        encoding: FileSystem.EncodingType.Base64,
      }),
      Promise.resolve(getCriticalFields(metadata)),
    ]);

    const hashingPromises = [
      ...Object.values(criticalFields).map(value =>
        Crypto.digestStringAsync(
          Crypto.CryptoDigestAlgorithm.SHA256,
          value
        )
      ),
      Crypto.digestStringAsync(
        Crypto.CryptoDigestAlgorithm.SHA256,
        base64Data
      )
    ];

    const leaves = await Promise.all(hashingPromises);
    const merkleTree = await MerkleTree.create(leaves);

    return merkleTree.getRootHash();

  } catch (error) {
    console.error('Hash computation failed:', error);
    return null;
  }
};