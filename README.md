# DataDAO Feeder

A tool to feed price data to DataDAO smart contracts using Reclaim Protocol's ZK-Fetch technology. The feeder fetches data from specified APIs and submits it to the blockchain with zero-knowledge proofs.

## Quick Start ⚡

Just run this single command:
```bash
curl -s https://raw.githubusercontent.com/reclaimprotocol/datadao-feeder/main/setup-feeder.sh | bash -s -- \
  -s "YOUR_ZKFETCH_SECRET_KEY" \
  -n "arbitrum-mainnet" \
  -u "YOUR_API_URL" \
  -i "UPDATE_INTERVAL"
```

### Parameters Explained 📝

- `-s`: Your private key for signing transactions (required)
- `-n`: Network name - `arbitrum-mainnet` or `base-mainnet` (required)
- `-u`: API URL to fetch data from (required)
- `-i`: Update interval in seconds (required)

### Example Command 💡

Here's a complete example that feeds ETH/USDC price data from Binance every hour:

```bash
curl -s https://raw.githubusercontent.com/reclaimprotocol/datadao-feeder/main/setup-feeder.sh | bash -s -- \
  -s "0xff8a3923eb5e5bc5217b67add9f9cb0c9a5094f262e1d1dfd3fe0748d9694fed" \
  -n "arbitrum-mainnet" \
  -u "https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDC" \
  -i "3600"
```

## What Does It Do? 🤔

When you run the command, it will:
1. Clone the repository
2. Install all required dependencies
3. Create configuration files
4. Start the feeder automatically

The feeder will then:
1. Connect to your specified API endpoint
2. Generate zero-knowledge proofs of the data
3. Submit the data to the DataDAO smart contract
4. Repeat this process based on your specified interval

## Supported Networks 🌐

| Network | Chain ID | Explorer |
|---------|----------|----------|
| Arbitrum Mainnet | 42161 | [Arbiscan](https://arbiscan.io/) |
| Base Mainnet | 8453 | [Basescan](https://basescan.org/) |

## Requirements 📋

- Operating System: Linux or macOS
- Internet connection
- Node.js (automatically installed if missing)
- **Wallet Requirements:**
  - The wallet address associated with your private key must have:
    - ETH for gas fees on Arbitrum (if using arbitrum-mainnet)
    - ETH for gas fees on Base (if using base-mainnet)
  - Recommended minimum balance: 0.001 ETH

> 💡 **Tip**: You can check your wallet balance on:
> - Arbitrum: [Arbiscan](https://arbiscan.io/)
> - Base: [Basescan](https://basescan.org/)

## Technical Details 🔧

The feeder uses:
- Reclaim Protocol's ZK-Fetch for secure data fetching
- Ethers.js for blockchain interactions
- Environment variables for configuration
- Automatic retry mechanisms for failed transactions

## Common Issues & Solutions 🛠️

1. **Invalid Private Key**
   - Ensure your private key starts with "0x"
   - Verify the key has exactly 64 characters after "0x"

2. **Network Connection**
   - Check your internet connection
   - Verify the RPC endpoint is accessible

3. **API Issues**
   - Confirm the API URL is correct
   - Ensure the API is publicly accessible
   - Check if API requires authentication

## Security Considerations 🔒

- Never share your private key
- Use a dedicated wallet for feeding data
- Keep sufficient funds for gas fees
- Monitor the feeder's activity regularly

## Support & Resources 📚

- [Reclaim Protocol Docs](https://docs.reclaimprotocol.org/)
- [GitHub Repository](https://github.com/reclaimprotocol/datadao-feeder)

## License 📄

ISC

## Contributing 🤝

Contributions are welcome! Please feel free to submit issues and pull requests.

---