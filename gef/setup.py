# Always prefer setuptools over distutils
from setuptools import setup, find_packages
# To use a consistent encoding
from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))
long_description = "See website for more info."

setup(
    name='gef',

    version='0.0.1',

    description='Install GEF as a pip module',
    long_description=long_description,

    # You can just specify the packages manually here if your project is
    # simple. Or you can use find_packages().
    packages=find_packages(exclude=['contrib', 'docs', 'tests']),

    install_requires=['ropper','keystone-engine','ropgadget','unicorn'],

    entry_points={
        'console_scripts': [
            'gef = gef.gef:run',
        ],
    },

)

