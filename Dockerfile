FROM python:2

RUN pip install pygraphviz numpy scipy
RUN pip install decision-tree-id3

RUN apt-get update && apt-get install -f -y graphviz

ADD . /altar
WORKDIR /altar
