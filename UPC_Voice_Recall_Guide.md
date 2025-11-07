# UPC Voice Recall Guide - Voice Agent LLM

## Overview
This guide provides quick reference for using a voice agent LLM to recall and work with UPC (Universal Product Code) information efficiently.

## Voice Commands for UPC Recall

### Basic UPC Lookup
```
"Look up UPC [code]"
"What product has UPC [code]?"
"Find information for barcode [code]"
```

### Quick Recall Format
When speaking UPC codes to the voice agent, use clear enunciation:
- Speak digits individually: "0-7-2-1-6-5-0-0-0-1-2-3"
- For zeros: Say "zero" not "oh"
- Pause briefly between digit groups for clarity

### Common Voice Agent Queries

#### Product Information
```
"Tell me about UPC [code]"
"What are the details for UPC [code]?"
"Describe the product with barcode [code]"
```

#### Validation
```
"Is UPC [code] valid?"
"Check barcode [code]"
"Validate this UPC: [code]"
```

#### Batch Recall
```
"I need to recall multiple UPCs"
"Start UPC batch entry mode"
"Add UPC [code] to my list"
```

## UPC Format Reference

### UPC-A (12 digits)
- Format: `XXX-XXX-XXX-XXX`
- Example: `012345678905`
- Most common format in North America

### UPC-E (8 digits)
- Format: `XXXXXXXX`
- Example: `01234565`
- Compressed version of UPC-A

### Check Digit Calculation
The last digit is a check digit calculated using modulo 10 algorithm.

## Voice Agent Best Practices

### For Clear Recognition
1. **Speak at moderate pace** - Not too fast, not too slow
2. **Enunciate digits clearly** - Each digit should be distinct
3. **Use confirmation** - Ask agent to repeat back the code
4. **Group digits logically** - Use natural pauses (e.g., groups of 3 or 4)

### Example Interaction
```
User: "Voice agent, look up UPC"
Agent: "Please provide the UPC code"
User: "Zero seven two one six five... zero zero zero one two three"
Agent: "Confirming UPC: 0-7-2-1-6-5-0-0-0-1-2-3. Looking up information..."
User: "Correct, proceed"
```

## Quick Reference Commands

| Task | Voice Command |
|------|---------------|
| Single lookup | "Look up UPC [code]" |
| Add to inventory | "Add UPC [code] to inventory" |
| Remove item | "Remove UPC [code]" |
| Check stock | "Check stock for UPC [code]" |
| Price inquiry | "What's the price for UPC [code]?" |
| History | "Show history for UPC [code]" |

## Common UPC Prefixes

| Prefix | Region/Type |
|--------|-------------|
| 0-1 | United States & Canada |
| 2 | In-store/Variable weight |
| 3 | Pharmaceuticals |
| 4 | In-store/Loyalty cards |
| 5 | Coupons |
| 6-9 | Various countries |

## Troubleshooting Voice Recognition

### If code isn't recognized:
1. Speak slower and more clearly
2. Use alternate phrasing: "The digits are..."
3. Spell it out: "U-P-C zero seven two..."
4. Use manual entry fallback: "Let me type this code"

### Tips for Noisy Environments
- Move to quieter area
- Use push-to-talk if available
- Speak closer to microphone
- Increase volume slightly without shouting

## Integration with Voice Agent LLM

### Setup Prompt Template
```
"I'm going to provide UPC codes for product lookup.
Please confirm each code before processing.
Format responses with product name, description, and price when available."
```

### Batch Processing
```
"Start batch UPC session"
[Provide multiple codes]
"End batch session and summarize"
```

### Context Retention
```
"Remember this UPC for later: [code]"
"Recall the UPC I mentioned earlier"
"Compare this UPC with the previous one"
```

## Advanced Features

### Natural Language Queries
```
"What's the UPC for Coca-Cola 12oz can?"
"Find me UPCs in the beverage category"
"Show me all UPCs added today"
```

### Voice Macros
Create custom shortcuts:
- "Quick scan" = Look up and add to cart
- "Price check" = Look up and read price only
- "Inventory add" = Look up and add to inventory database

## Safety & Accuracy

- **Always confirm** critical UPCs before processing
- **Double-check** pricing and product matches
- **Verify check digit** for manual entries
- **Use visual confirmation** when available

## Notes for Developers

When implementing voice UPC recall in LLM agents:
- Include confidence scoring for recognized digits
- Implement automatic check digit validation
- Provide audio feedback for confirmations
- Support both continuous and discrete digit recognition
- Include error correction and re-prompt logic

---

## Quick Start Checklist

- [ ] Configure voice agent with UPC lookup capability
- [ ] Test digit recognition accuracy
- [ ] Set up confirmation prompts
- [ ] Create custom command shortcuts
- [ ] Test in typical usage environment
- [ ] Set up fallback methods (manual entry, camera scan)

## Resources

- UPC Database APIs for integration
- Voice recognition best practices
- Barcode scanning alternatives
- Product information databases

---

*Last Updated: 2025-11-07*
