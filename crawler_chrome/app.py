import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
# from webdriver_manager.chrome import ChromeDriverManager
# from selenium.webdriver.remote.webdriver import WebDriver

# URL to connect to the running Selenium container
selenium_url = os.getenv('REMOTE_SELENIUM', 'http://localhost:4444/wd/hub')

# Set Chrome options
chrome_options = Options()
chrome_options.add_argument('--headless')  # Run Chrome in headless mode
# chrome_options.add_argument('--no-sandbox')  # Disable sandbox for Docker
chrome_options.add_argument('--disable-dev-shm-usage')  # Disable dev/shm usage (for Docker containers)

# Create the WebDriver instance with the Selenium Grid URL
driver = webdriver.Remote(
    command_executor=selenium_url,
    options=chrome_options
)

# Example: Open a website
driver.get("https://www.example.com")

# Interact with the webpage (e.g., find an element)
title = driver.title
print(f">>>>>>>> Title of the page is: {title}")

# # Example: Find a specific element by its tag name
# element = driver.find_element(By.TAG_NAME, 'h1')
# print(f"First h1 element text: {element.text}")



# Close the browser
driver.quit()
