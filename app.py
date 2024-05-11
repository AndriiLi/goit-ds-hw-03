from bottle import Bottle, run, template, static_file, redirect, HTTPError, request, response, abort
from bson import ObjectId
from pymongo import MongoClient
from pymongo.results import DeleteResult, UpdateResult
import json

from scrapper import Scrapper

app = Bottle()

TARGET_URL = 'https://quotes.toscrape.com'

try:
    mongo_client = MongoClient(
        'mongo',
        27017,
        username="root",
        password="password"
    )

    # mongo_client = MongoClient(
    #     '127.0.0.1',
    #     27017,
    #     username="root",
    #     password="password"
    # )

    mongo_db = mongo_client.cats
    mongo_quotes = mongo_client.quotes
    mongo_authors = mongo_client.authors

except Exception as e:
    print(e)


@app.error(code=404)
@app.error(code=500)
def error404(errors: HTTPError):
    print(errors.status, '-', errors.body)
    return template('http_errors', errors=errors)


@app.route('/static/:folder/:filename')
def send_static(folder, filename):
    print(folder, filename)
    return static_file(filename, root=f"./static/{folder}")


@app.route('/', method='GET')
def index():
    search = request.query.q.strip()
    cats = list(mongo_db.cats.find(
        {"$or": [{"name": {"$regex": search}}, {"age": search}, {"features": {"$all": [search]}}]}
    ))
    return template('cats_table', cat_list=cats, search=search)


@app.route('/create', method='POST')
def create():
    name = request.forms.get('name', '')
    age = request.forms.get('age', 0)
    features = request.forms.get('features', '')
    print(name, age, features)
    mongo_db.cats.insert_one({
        "name": name.strip(),
        "age": age.strip(),
        "features": [f.strip() for f in str(features).split(',')]
    })
    redirect('/')


@app.route('/show/:cat_id', method='GET')
def show(cat_id: str):
    cat = mongo_db.cats.find_one({'_id': ObjectId(cat_id)})
    cat['_id'] = str(cat['_id'])
    response.content_type = 'application/json'
    return json.dumps(cat)


@app.route('/delete_cats', method='POST')
def delete_cats():
    mongo_db.cats.delete_many({})
    response.content_type = 'application/json'
    return dict({'ok': 'true'})


@app.route('/update/:cat_id', method='POST')
def update(cat_id: str):
    name = request.forms.get('name', "")
    age = request.forms.get('age', 0)
    features = request.forms.get('features', "")
    result: UpdateResult = mongo_db.cats.update_one(
        {"_id": ObjectId(cat_id)},
        {"$set": {
            "name": name,
            "age": age,
            "features": [f.strip() for f in str(features).split(',')]
        }},
        upsert=True)
    if result.acknowledged:
        return redirect('/')

    abort(code=404)


@app.route('/delete', method='POST')
def delete():
    cat_id = request.forms.get('id', '')
    if len(cat_id):
        result: DeleteResult = mongo_db.cats.delete_one({'_id': ObjectId(cat_id)})
        if result.acknowledged:
            return redirect('/')

    abort(code=404)


@app.route('/scrape_quotes', method='GET')
def scrape_quotes():
    scrapper = Scrapper(TARGET_URL, True, False)
    res = scrapper.run_scrape()
    scrapper.save_to_file('quotes.json', res['quotes'])
    scrapper.save_to_database('quotes.json', mongo_quotes, 'quotes')

    response.content_type = 'application/json'
    return dict({'ok': 'true'})


@app.route('/quotes', method='GET')
def quotes():
    search = request.query.q.strip()
    quotes_list = list(mongo_quotes.quotes.find(
        {"$or": [{"quotes": {"$regex": search}}, {"author": {"$regex": search}}, {"tags": {"$all": [search]}}]},
    ).sort({'author': 1}))

    return template('quotes', quotes=quotes_list, search=search, count=len(quotes_list))


@app.route('/delete_quotes', method='GET')
def delete_quotes():
    mongo_quotes.quotes.delete_many({})
    response.content_type = 'application/json'
    return dict({'ok': 'true'})


@app.route('/authors', method='GET')
def authors():
    search = request.query.q.strip()
    authors_list = list(mongo_authors.authors.find(
        {"$or": [{"fullname": {"$regex": search}}]},
    ).sort({'fullname': 1}))
    return template('authors', authors=authors_list, search=search, count=len(authors_list))


@app.route('/scrape_authors', method='GET')
def scrape_authors():
    scrapper = Scrapper(TARGET_URL, False, True)
    res = scrapper.run_scrape()

    scrapper.save_to_file('authors.json', res['authors'])
    scrapper.save_to_database('authors.json', mongo_authors, 'authors')

    response.content_type = 'application/json'
    return dict({'ok': 'true'})


@app.route('/delete_authors', method='GET')
def delete_authors():
    mongo_authors.authors.delete_many({})
    response.content_type = 'application/json'
    return dict({'ok': 'true'})


run(app=app, host='0.0.0.0', port=5000, debug=True, reloader=True)
