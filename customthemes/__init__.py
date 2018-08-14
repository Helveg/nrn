import html2
import sphinx.writers.html
import sphinx.ext.mathjax

def setup(app):
    """Setup conntects events to the sitemap builder""" 
    app.set_translator('html', html2.HTMLTranslator)    