# RecipeReady Xcode Setup Guide

## 1. Add Share Extension Target

1. Open `RecipeReady.xcodeproj` in Xcode
2. File → New → Target
3. Select **Share Extension**, click Next
4. Name: `ShareExtension`
5. Bundle Identifier: `com.recipeready.app.ShareExtension`
6. Click Finish

## 2. Configure App Group

### Main App Target:
1. Select **RecipeReady** target
2. Signing & Capabilities → + Capability → **App Groups**
3. Add: `group.com.recipeready.shared`

### Share Extension Target:
1. Select **ShareExtension** target
2. Signing & Capabilities → + Capability → **App Groups**
3. Add: `group.com.recipeready.shared`

## 3. Add URL Scheme (for extension → app communication)

1. Select **RecipeReady** target
2. Info → URL Types → Add (+)
3. Identifier: `com.recipeready.app`
4. URL Schemes: `recipeready`
5. Role: Editor

## 4. Link Share Extension Files

The Share Extension files are in `ShareExtension/` folder:
- `ShareViewController.swift` (already created)
- `Info.plist` (already created)
- `ShareExtension.entitlements` (already created)

**In Xcode:**
1. Select ShareExtension target
2. Delete the auto-generated `ShareViewController.swift`
3. Drag `ShareExtension/ShareViewController.swift` into the target
4. Ensure "Copy items if needed" is unchecked
5. Target membership: ShareExtension only

## 5. Share Service Files Between Targets

These files need to be in **BOTH** targets:
- `Services/AudioExtractor.swift`
- `Services/AppGroupManager.swift`
- `Model/Ingredient.swift`
- `Model/CookingStep.swift`

**For each file:**
1. Select the file in Project Navigator
2. Show File Inspector (right panel)
3. Under "Target Membership", check both:
   - ☑️ RecipeReady
   - ☑️ ShareExtension

## 6. Build & Run

1. Select **RecipeReady** scheme
2. Build (⌘B) to verify no errors
3. Run on device (Share Extensions don't work in Simulator)

## 7. Test Share Extension

1. Install app on device
2. Open Instagram/TikTok
3. Find a recipe video
4. Tap Share → RecipeReady
5. Extension should process and open main app
