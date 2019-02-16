"""A pure Python implementation of import."""
__all__ = ['__import__', 'import_module', 'invalidate_caches', 'reload']

# Bootstrap help #####################################################

# Until bootstrapping is complete, DO NOT import any modules that attempt
# to import importlib._bootstrap (directly or indirectly). Since this
# partially initialised package would be present in sys.modules, those
# modules would get an uninitialised copy of the source version, instead
# of a fully initialised version (either the frozen one or the one
# initialised below if the frozen one is not available).
import _imp  # Just the builtin component, NOT the full Python module
import sys

try:
    import _frozen_importlib as _bootstrap
except ImportError:
    from . import _bootstrap
    _bootstrap._setup(sys, _imp)
else:
    # importlib._bootstrap is the built-in import, ensure we don't create
    # a second copy of the module.
    _bootstrap.__name__ = 'importlib._bootstrap'
    _bootstrap.__package__ = 'importlib'
    try:
        _bootstrap.__file__ = __file__.replace('__init__.py', '_bootstrap.py')
    except NameError:
        # __file__ is not guaranteed to be defined, e.g. if this code gets
        # frozen by a tool like cx_Freeze.
        pass
    sys.modules['importlib._bootstrap'] = _bootstrap

# To simplify imports in test code
_w_long = _bootstrap._w_long
_r_long = _bootstrap._r_long

# Fully bootstrapped at this point, import whatever you like, circular
# dependencies and startup overhead minimisation permitting :)

import types
import warnings


# Public API #########################################################

from ._bootstrap import __import__


def invalidate_caches():
    """Call the invalidate_caches() method on all meta path finders stored in
    sys.meta_path (where implemented)."""
    for finder in sys.meta_path:
        if hasattr(finder, 'invalidate_caches'):
            finder.invalidate_caches()


def find_loader(name, path=None):
    """Return the loader for the specified module.

    This is a backward-compatible wrapper around find_spec().

    This function is deprecated in favor of importlib.util.find_spec().

    """
    warnings.warn('Use importlib.util.find_spec() instead.',
                  DeprecationWarning, stacklevel=2)
    try:
        loader = sys.modules[name].__loader__
        if loader is None:
            raise ValueError('{}.__loader__ is None'.format(name))
        else:
            return loader
    except KeyError:
        pass
    except AttributeError:
        raise ValueError('{}.__loader__ is not set'.format(name))

    spec = _bootstrap._find_spec(name, path)
    # We won't worry about malformed specs (missing attributes).
    if spec is None:
        return None
    if spec.loader is None:
        if spec.submodule_search_locations is None:
            raise ImportError('spec for {} missing loader'.format(name),
                              name=name)
        raise ImportError('namespace packages do not have loaders',
                          name=name)
    return spec.loader


def import_module(name, package=None):
    """Import a module.

    The 'package' argument is required when performing a relative import. It
    specifies the package to use as the anchor point from which to resolve the
    relative import to an absolute import.

    """
    level = 0
    if name.startswith('.'):
        if not package:
            msg = ("the 'package' argument is required to perform a relative "
                   "import for {!r}")
            raise TypeError(msg.format(name))
        for character in name:
            if character != '.':
                break
            level += 1
    return _bootstrap._gcd_import(name[level:], package, level)


_RELOADING = {}


def reload(module):
    """Reload the module and return it.

    The module must have been successfully imported before.

    """
    if not module or not isinstance(module, types.ModuleType):
        raise TypeError("reload() argument must be module")
    try:
        name = module.__spec__.name
    except AttributeError:
        name = module.__name__

    if sys.modules.get(name) is not module:
        msg = "module {} not in sys.modules"
        raise ImportError(msg.format(name), name=name)
    if name in _RELOADING:
        return _RELOADING[name]
    _RELOADING[name] = module
    try:
        parent_name = name.rpartition('.')[0]
        if parent_name:
            try:
                parent = sys.modules[parent_name]
            except KeyError:
                msg = "parent {!r} not in sys.modules"
                raise ImportError(msg.format(parent_name), name=parent_name)
            else:
                pkgpath = parent.__path__
        else:
            pkgpath = None
        target = module
        spec = module.__spec__ = _bootstrap._find_spec(name, pkgpath, target)
        methods = _bootstrap._SpecMethods(spec)
        methods.exec(module)
        # The module may have replaced itself in sys.modules!
        return sys.modules[name]
    finally:
        try:
            del _RELOADING[name]
        except KeyError:
            pass
