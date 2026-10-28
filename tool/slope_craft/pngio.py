"""순수 python PNG 디코드/인코드 (zlib + struct).

이 저장소에는 PIL·numpy가 설치돼 있지 않고, 1회성 도구에 의존성을 추가할
이유도 없어서 직접 구현한다. 슬로프크래프트 에셋은 전부 8bit PNG다.
"""

import struct
import zlib

__all__ = ['decode', 'encode_rgb']

_BPP = {0: 1, 2: 3, 4: 2, 6: 4}


def decode(path):
    """PNG → (width, height, bytes_per_pixel, pixels).

    pixels는 행 우선 바이트열이고, 픽셀 (x, y)의 채널 c는
    pixels[(y * width + x) * bpp + c] 다. 팔레트(color type 3)는 쓰지 않는다.
    """
    data = open(path, 'rb').read()
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise ValueError(f'PNG이 아님: {path}')

    i, idat = 8, bytearray()
    width = height = bpp = None
    while i < len(data):
        (length,) = struct.unpack('>I', data[i:i + 4])
        kind = data[i + 4:i + 8]
        body = data[i + 8:i + 8 + length]
        if kind == b'IHDR':
            width, height, depth, color, _comp, _filt, interlace = struct.unpack(
                '>IIBBBBB', body[:13])
            if depth != 8:
                raise ValueError(f'8bit만 지원: {path} (depth={depth})')
            if interlace:
                raise ValueError(f'인터레이스 미지원: {path}')
            if color not in _BPP:
                raise ValueError(f'color type {color} 미지원: {path}')
            bpp = _BPP[color]
        elif kind == b'IDAT':
            idat += body
        elif kind == b'IEND':
            break
        i += 8 + length + 4

    raw = zlib.decompress(bytes(idat))
    stride = width * bpp
    out = bytearray(stride * height)
    prev = bytearray(stride)
    pos = 0
    for row in range(height):
        f = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride
        # PNG 행 필터 역변환 (0=없음은 그대로)
        if f == 1:
            for x in range(bpp, stride):
                line[x] = (line[x] + line[x - bpp]) & 255
        elif f == 2:
            for x in range(stride):
                line[x] = (line[x] + prev[x]) & 255
        elif f == 3:
            for x in range(stride):
                a = line[x - bpp] if x >= bpp else 0
                line[x] = (line[x] + ((a + prev[x]) >> 1)) & 255
        elif f == 4:
            for x in range(stride):
                a = line[x - bpp] if x >= bpp else 0
                c = prev[x - bpp] if x >= bpp else 0
                b = prev[x]
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + pred) & 255
        elif f != 0:
            raise ValueError(f'알 수 없는 행 필터 {f}: {path}')
        out[row * stride:(row + 1) * stride] = line
        prev = line
    return width, height, bpp, bytes(out)


def encode_rgb(path, width, height, pixels):
    """RGB 바이트열(알파 없음)을 PNG으로 저장한다. 행 필터는 전부 0."""
    raw = bytearray()
    stride = width * 3
    for y in range(height):
        raw.append(0)
        raw += pixels[y * stride:(y + 1) * stride]

    def chunk(kind, body):
        return (struct.pack('>I', len(body)) + kind + body
                + struct.pack('>I', zlib.crc32(kind + body) & 0xFFFFFFFF))

    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)))
        f.write(chunk(b'IDAT', zlib.compress(bytes(raw), 6)))
        f.write(chunk(b'IEND', b''))
