import blockchain_bridge

def test_blockchain():
    print("===============================================================================")
    print("   TESTING BLOCKCHAIN SMART CONTRACT BRIDGE")
    print("===============================================================================\n")

    print("1. Checking Ganache / Ethereum Node status...")
    online = blockchain_bridge.is_blockchain_online()
    print("   - Ethereum Node Online:", online)

    print("\n2. Logging File Upload On-Chain...")
    tx1 = blockchain_bridge.log_upload_on_chain("1", "contract_test.pdf", "Owner1", "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    print("   - File Upload TxHash:", tx1)

    print("\n3. Logging Access Grant On-Chain...")
    tx2 = blockchain_bridge.grant_access_on_chain("1", "user@example.com", "rekey_sample_123")
    print("   - Access Grant TxHash:", tx2)

    assert tx1.startswith("0x") and len(tx1) >= 42
    assert tx2.startswith("0x") and len(tx2) >= 42

    print("\n[SUCCESS] Blockchain Smart Contract integration verified!")

if __name__ == '__main__':
    test_blockchain()
