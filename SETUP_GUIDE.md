# Quick Setup Guide - UPC Voice App

## 🚀 Quick Start (5 minutes)

### Step 1: Open in Xcode
```bash
cd Cluadepdfvoice
open UPCVoiceApp
```

In Xcode, you'll need to create a new iOS project and add these files to it. Here's how:

1. **Create New Project in Xcode:**
   - Open Xcode
   - File > New > Project
   - Choose "App" template
   - Product Name: `UPCVoiceApp`
   - Interface: SwiftUI
   - Language: Swift
   - Create the project

2. **Add the Source Files:**
   - Delete the default `ContentView.swift` and `UPCVoiceAppApp.swift`
   - Drag and drop all files from the repository into your Xcode project:
     - Models folder
     - Services folder
     - ViewModels folder
     - Views folder
     - `UPCVoiceAppMain.swift`
     - `Info.plist`

3. **Configure Info.plist:**
   - Select your project's Info tab
   - Add the microphone and speech recognition usage descriptions from the provided `Info.plist`

### Step 2: Get Your Free API Key

**Google Gemini API (Required)**
1. Go to: https://ai.google.dev/
2. Click "Get API Key" (or "Get Started")
3. Sign in with Google
4. Create new API key
5. Copy the key (starts with `AIza...`)

**Free Tier Limits:**
- ✅ 60 requests/minute
- ✅ 1,500 requests/day
- ✅ No credit card needed

### Step 3: Configure Bundle & Signing

1. In Xcode, select the project in the navigator
2. Select the target `UPCVoiceApp`
3. Go to "Signing & Capabilities"
4. Choose your Team
5. Xcode will automatically create a unique bundle identifier

### Step 4: Run the App

1. Select a simulator (iPhone 14 recommended) or your device
2. Press `Cmd + R` or click the Run button ▶️
3. Wait for the app to build and launch

### Step 5: First Time Setup

When the app launches:

1. **Grant Permissions:**
   - Allow Microphone Access
   - Allow Speech Recognition

2. **Add API Key:**
   - Go to Settings tab (⚙️ icon)
   - Paste your Gemini API key
   - Tap "Save API Key"

3. **Test Voice Input:**
   - Go to Home tab
   - Tap the microphone button
   - Say: "zero one two three four five six seven eight nine zero one"
   - The app should recognize the UPC

## 📱 Using the App

### Voice Commands

**Lookup a Product:**
1. Tap the big microphone button
2. Speak the UPC clearly: "zero seven two one six five..."
3. Tap to stop recording
4. View product information

**Add to Inventory:**
- "Add to inventory"
- "Add 5 to inventory"
- Or tap on product card and use the form

### Manual Entry

1. Type UPC in the text field
2. Tap the magnifying glass icon 🔍
3. View product details

## 🛠️ Troubleshooting

### Build Errors

**"No such module 'Speech'"**
- This is a standard iOS framework, ensure you're targeting iOS 15+

**Code Signing Error**
- Select your development team in Signing & Capabilities
- Change bundle identifier if needed

### Runtime Issues

**Voice Recognition Not Working**
- Go to iOS Settings > Privacy > Microphone
- Enable for UPCVoiceApp
- Do the same for Speech Recognition

**API Errors**
- Check internet connection
- Verify API key is correct
- Check you haven't exceeded free tier limits

**Product Not Found**
- Some UPCs may not be in the free database
- Try a common product (Coca-Cola: 049000050103)
- You can manually add products

## 🧪 Test UPCs

Try these popular product UPCs to test:

- **049000050103** - Coca-Cola 12oz Can
- **012000161155** - Pepsi 12oz Can
- **028400064958** - Gatorade 32oz
- **078000082609** - Nabisco Oreos
- **016000275287** - Planters Peanuts

## 📊 File Structure Reference

```
UPCVoiceApp/
├── Models/
│   ├── Product.swift           # Product data structure
│   └── InventoryItem.swift     # Inventory item structure
├── Services/
│   ├── VoiceRecognitionService.swift  # iOS voice input
│   ├── GeminiAIService.swift         # AI processing
│   ├── UPCLookupService.swift        # Product lookup
│   └── InventoryManager.swift        # Storage & management
├── ViewModels/
│   └── MainViewModel.swift     # App state coordinator
├── Views/
│   ├── ContentView.swift       # Main UI
│   ├── ProductDetailView.swift # Product details
│   ├── InventoryListView.swift # Inventory list
│   └── SettingsView.swift      # Settings
└── UPCVoiceAppMain.swift      # App entry point
```

## 🎯 Next Steps

Once setup is complete:

1. ✅ Test voice recognition with a UPC
2. ✅ Look up a product
3. ✅ Add item to inventory
4. ✅ View your inventory
5. ✅ Try exporting to CSV

## 💡 Tips for Best Results

### Voice Recognition:
- Speak in a quiet environment
- Enunciate each digit clearly
- Use "zero" not "oh"
- Pause briefly between digit groups

### API Usage:
- Free tier is generous but has limits
- Cache frequently used products
- Consider upgrading for production use

## 🆘 Getting Help

**Common Issues:**

1. **App crashes on voice input**
   - Check microphone permissions
   - Restart app after granting permissions

2. **No products found**
   - Try well-known brand UPCs
   - Check internet connection
   - UPC database has limited coverage

3. **AI not responding**
   - Verify API key is saved
   - Check Gemini API dashboard for quota
   - Ensure internet connection

## 📚 Additional Resources

- [Google Gemini Documentation](https://ai.google.dev/docs)
- [UPCitemdb API Docs](https://www.upcitemdb.com/api)
- [iOS Speech Framework Guide](https://developer.apple.com/documentation/speech)

## ✨ Success!

You should now have a working UPC voice lookup and inventory management app!

Try saying: "zero four nine zero zero zero zero five zero one zero three" to look up a Coca-Cola can! 🎉
