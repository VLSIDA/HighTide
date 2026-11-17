#!/usr/bin/env python3
"""Optional, self-contained DEF PG geometry-audit parser regression."""
import gzip
import json
from pathlib import Path
import subprocess
import sys
import tempfile


def main():
    parser = Path(__file__).with_name('placement_pg_geometry.py')
    via = b'VIAS 1 ;\n- via1 + RECT M1 ( 0 0 ) ( 10 10 ) ;\nEND VIAS\n'
    route = b' + USE POWER\n + ROUTED M1 10 ( 0 0 ) ( 100 0 ) MASK 1 ;\n'
    connections = {
        'ordinary': b'( ordinary VDD )',
        'escaped_plus': rb'( escaped\+instance VDD )',
        'embedded_plus': b'( embedded+instance VDD )',
        'escaped_parentheses': rb'( escaped\(name\) VDD )',
        'multiline': b'(\n escaped\\+instance\n VDD\n )',
        'no_connections': b'',
        'inline_property': b'( ordinary VDD )',
    }
    with tempfile.TemporaryDirectory(prefix='placement-pg-geometry-check-') as directory:
        directory = Path(directory)

        def check(name, connection, geometry=route, vias=via, complete=True):
            source = directory / (name + '.def')
            suffix = b'END SPECIALNETS\n' if complete else b''
            separator = b' ' if name == 'inline_property' else b'\n'
            source.write_bytes(vias + b'SPECIALNETS 1 ;\n- VDD ' + connection
                               + separator + geometry + suffix)
            archive = directory / (name + '.gz')
            metadata = directory / (name + '.json')
            result = subprocess.run([sys.executable, str(parser), str(source),
                                     str(archive), str(metadata)],
                                    capture_output=True, text=True, timeout=10)
            if not complete:
                assert result.returncode != 0, 'Incomplete input was accepted'
                return None
            assert result.returncode == 0, result.stderr
            return json.loads(metadata.read_text())['sha256'], gzip.decompress(archive.read_bytes())

        baseline = check('ordinary', connections['ordinary'])
        for name, connection in connections.items():
            assert check(name, connection) == baseline, name + ' changed geometry-only output'
        assert check('route_changed', connections['ordinary'], route.replace(b'100 0', b'101 0')) != baseline
        assert check('via_changed', connections['ordinary'], vias=via.replace(b'10 10', b'11 10')) != baseline
        check('incomplete', connections['ordinary'], complete=False)
    print('PASS: 7 association forms, route/via sensitivity, incomplete-input rejection')


if __name__ == '__main__':
    main()
