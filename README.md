# XPath Extractor & Web Scraping Automation

## Overview
This project is designed to automate web scraping by extracting XPath elements dynamically from a webpage. It utilizes **Flutter** with **flutter_inappwebview** to render web pages and detect user interactions with web elements. The application captures clicked elements' XPath in real-time and displays them in a dedicated section of the interface.

## Features
- **Real-time XPath Recognition:** Detects and records XPath when a user hovers or clicks on an element.
- **Live Display of Extracted XPaths:** Displays the recognized XPaths in a UI panel.
- **Prevents Navigation on Click:** Ensures interactions don’t navigate away from the webpage.
- **Ideal for Web Scraping Automation:** Helps developers and testers gather accurate XPaths for automation.

## Screenshot
![XPath Extractor Screenshot](./image.png)

## Installation
1. **Clone the repository**:
   ```sh
   git clone https://github.com/your-username/xpath-extractor.git
   cd xpath-extractor
   ```
2. **Install dependencies**:
   ```sh
   flutter pub get
   ```
3. **Run the application**:
   ```sh
   flutter run
   ```

## Usage
- Open the application and navigate to any webpage.
- Hover over elements to see their XPath in the logs.
- Click on elements to save and display their XPath in the UI panel.

## Dependencies
Ensure you have the following dependencies in your `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_inappwebview: latest_version
```

## Future Enhancements
- **Export collected XPaths to a file**
- **Integrate with Selenium for direct automation**
- **Support for multiple web pages and session management**

## License
This project is licensed under the MIT License. Feel free to modify and use it as needed.
