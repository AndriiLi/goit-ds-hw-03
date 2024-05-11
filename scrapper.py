from pathlib import Path

import requests
from bs4 import BeautifulSoup
from contextlib import contextmanager
import json


class Scrapper:
    _url = None
    _scrape_quotes = False
    _scrape_authors = False
    _author_links = []

    def __init__(self, url_to_scrape, scrape_quotes=False, scrape_authors=False):
        self._url = url_to_scrape
        self._scrape_quotes = scrape_quotes
        self._scrape_authors = scrape_authors

    @classmethod
    def get_content(cls, url):
        html_doc = requests.get(url)
        if html_doc.status_code == 200:
            return BeautifulSoup(html_doc.text, 'lxml')

        print('Error while trying to scrape', url)
        return None

    @classmethod
    def scrape_quote(cls, quote) -> dict:
        return {
            "quote": quote.find('span', attrs={'class': 'text'}).text.strip().replace('“', '').replace('”', ''),
            "author": quote.find('small', attrs={'class': 'author'}).text.strip(),
            "tags": [tag.text.strip() for tag in quote.find_all('a', attrs={'class': 'tag'})]
        }

    def scrape_author(self, quote):
        link = quote.find('span').find_next_sibling('span').find('a').get('href')

        if link in self._author_links:
            return None

        self._author_links.append(link)

        soup = self.get_content(self._url + link)
        return {
            "fullname": soup.find('h3', attrs={'class': 'author-title'}).text.strip(),
            "born_date": soup.find('span', attrs={'class', 'author-born-date'}).text.strip(),
            "born_location": soup.find('span', attrs={'class': 'author-born-location'}).text.strip(),
            "description": soup.find('div', attrs={'class': 'author-description'}).text.strip(),
        }

    @classmethod
    def get_next_link(cls, soup) -> str | None:
        next_page = soup.select('ul.pager li.next a')
        if len(next_page):
            for link in next_page:
                next_url = link.get('href')
                if next_url:
                    print(next_url)
                    return next_url
        return None

    def run_scrape(self, url=None) -> dict:
        if url is None:
            url = self._url

        quotes = []
        authors = []

        soup = self.get_content(url)
        if soup is None:
            return {quotes: quotes, authors: authors}

        quote_list = soup.select('div.quote')
        for quote in quote_list:
            self._scrape_quotes and quotes.append(self.scrape_quote(quote))
            if self._scrape_authors:
                author = self.scrape_author(quote)
                author and authors.append(author)

        next_link = self.get_next_link(soup)
        if next_link:
            result = self.run_scrape(self._url + next_link)
            self._scrape_quotes and quotes.extend(result['quotes'])
            self._scrape_authors and authors.extend(result['authors'])

        self._author_links.clear()
        return {'quotes': quotes, 'authors': authors}

    @contextmanager
    def save_to_file(self, filename, data):
        path = Path('./static/download/' + filename).absolute()
        with open(path, 'w', encoding='utf8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)

    @contextmanager
    def save_to_database(self, filename, database, collections):
        path = Path('./static/download/' + filename).absolute()
        with open(path, 'r') as f:
            for item in json.load(f):
                database[collections].insert_one(item)
