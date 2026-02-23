# Adding Sparkle from a Local Copy

This document explains what to download and how to add [Sparkle](https://github.com/sparkle-project/Sparkle) to an Xcode project using a local copy instead of fetching it directly from the internet through Xcode's Swift Package Manager.

## What to Download

Sparkle provides its source code as a Swift package. To add it locally, download the **source code** archive from the Sparkle releases page on GitHub:

1. Open https://github.com/sparkle-project/Sparkle/releases in a browser.
2. Choose the release you want (e.g. **2.8.1**).
3. Under **Assets**, download either **Source code (zip)** or **Source code (tar.gz)**.

> Do **not** download `Sparkle-X.Y.Z.tar.xz`. That archive contains only the pre-built XCFramework and cannot be used as a local Swift package through Xcode's package manager.

## How to Add Sparkle to Xcode from the Local Copy

### 1 – Extract the Archive

Unzip or untar the downloaded file. You will get a folder named `Sparkle-2.8.1` (or whichever version you downloaded) that contains a `Package.swift` file at its root. This folder is the local Swift package.

### 2 – Open "Add Package Dependencies" in Xcode

With your Xcode project open, choose **File ▸ Add Package Dependencies…** from the menu bar.

### 3 – Add the Local Package

In the package search dialog, click the **Add Local…** button in the bottom-left corner, navigate to the `Sparkle-2.8.1` folder you extracted, select it, and click **Add Package**.

### 4 – Select the Library

Xcode will display a list of available package products. Select **Sparkle** and make sure it is added to your application target, then click **Add Package**.

### 5 – Verify the Integration

The Sparkle package should now appear under **Package Dependencies** in the Project navigator. You can import it in Swift files as usual:

```swift
import Sparkle
```

## Notes

- After adding the local package, Xcode records the path in `Package.resolved` as a `localSourceControl` entry rather than a `remoteSourceControl` entry. If you share the Xcode project with others, they will need the Sparkle folder at the same relative path, or they must re-add the package from their own local copy or from the internet.
- To switch back to the online version at any time, remove the local package from **Project Settings ▸ Package Dependencies** and re-add it using the URL `https://github.com/sparkle-project/Sparkle`.
