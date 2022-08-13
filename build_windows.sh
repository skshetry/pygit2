#!/bin/sh

set -x # Print every command and variable
set -e # Fail fast

PYTHON=${PYTHON:-python3}
PREFIX="${PREFIX:-$(pwd)/ci/$PYTHON_TAG}"

if [ "$CIBUILDWHEEL" = "1" ]; then
    rm -rf ci
    mkdir ci || true
    cd ci
else
    # Create a virtual environment
    $PYTHON -m venv $PREFIX
fi

$PYTHON -m pip install -U pip wheel
git clone --depth=1 -b v${LIBGIT2_VERSION} https://github.com/libgit2/libgit2.git libgit2
cd libgit2
cmake . -DBUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} -G '${CMAKE_GENERATOR}'
cmake --build . --target install
cd ..

# Tests
if [ "$1" = "test" ]; then
    shift
    if [ -n "$WHEELDIR" ]; then
        $PREFIX/bin/pip install $WHEELDIR/pygit2*-$PYTHON_TAG-*.whl
    fi
    $PREFIX/bin/pip install -r requirements-test.txt
    $PREFIX/bin/pytest --cov=pygit2
fi

