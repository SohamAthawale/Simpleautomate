import sys
import time
import json
import logging
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

# Logging Configuration
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

def detect_elements(url):
    # Configure Chrome Options for headless execution
    chrome_options = Options()
    chrome_options.add_argument("--headless")  # Run without GUI
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    # Launch Chrome WebDriver
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
    driver.get(url)

    interactable_tags = {"input", "button", "select", "textarea"}
    elements_data = []

    elements = driver.find_elements(By.XPATH, "//*")

    for elem in elements:
        if elem.tag_name.lower() in interactable_tags and elem.is_displayed():
            elements_data.append({
                "tag": elem.tag_name,
                "xpath": f"//*[@id='{elem.get_attribute('id')}']" if elem.get_attribute("id") else "N/A",
                "class": elem.get_attribute("class"),
            })

    driver.quit()
    return elements_data

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No URL provided"}))
        sys.exit(1)

    url = sys.argv[1]
    result = detect_elements(url)
    print(json.dumps(result))  # Output JSON for Flutter
