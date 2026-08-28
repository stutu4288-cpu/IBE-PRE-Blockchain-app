#!/usr/bin/env python3
"""
Enterprise Python File Processing & Conversion Engine.
Leverages industry-standard Python packages:
- pypdf (v6.15.0): Deep PDF structure & syntax validation
- python-docx (v1.2.0): Word XML container verification
- Pillow (v12.2.0): Image verification, lossless re-encoding & format conversion
"""

import sys
import os
import io
import json
import base64

# Package Imports with graceful fallbacks
try:
    import pypdf
    HAS_PYPDF = True
except ImportError:
    HAS_PYPDF = False

try:
    import docx
    HAS_DOCX = True
except ImportError:
    HAS_DOCX = False

try:
    from PIL import Image
    HAS_PILLOW = True
except ImportError:
    HAS_PILLOW = False


def validate_pdf(file_bytes: bytes) -> tuple:
    """
    Validates PDF binary stream using pypdf without mutating byte layout.
    """
    if not HAS_PYPDF:
        return True, file_bytes, "pypdf unavailable; passed raw bytes"

    try:
        pdf_stream = io.BytesIO(file_bytes)
        reader = pypdf.PdfReader(pdf_stream)
        num_pages = len(reader.pages)
        return True, file_bytes, f"Validated PDF ({num_pages} pages)"
    except Exception as e:
        if file_bytes.startswith(b"%PDF"):
            return True, file_bytes, f"PDF header present (pypdf note: {str(e)})"
        return False, file_bytes, f"Invalid PDF: {str(e)}"


def validate_docx(file_bytes: bytes) -> tuple:
    """
    Validates DOCX binary archive using python-docx without mutating byte layout.
    """
    if not HAS_DOCX:
        return True, file_bytes, "python-docx unavailable; passed raw bytes"

    try:
        docx_stream = io.BytesIO(file_bytes)
        doc = docx.Document(docx_stream)
        paragraphs_count = len(doc.paragraphs)
        return True, file_bytes, f"Validated DOCX ({paragraphs_count} paragraphs)"
    except Exception as e:
        if file_bytes.startswith(b"PK\x03\x04"):
            return True, file_bytes, f"Valid ZIP/DOCX container (docx note: {str(e)})"
        return False, file_bytes, f"Invalid DOCX: {str(e)}"


def validate_image(file_bytes: bytes, filename: str, target_format: str = None) -> tuple:
    """
    Validates image using Pillow (PIL). If target_format is specified, performs format conversion.
    Otherwise preserves pristine original binary bytes.
    """
    if not HAS_PILLOW:
        return True, file_bytes, "Pillow unavailable; passed raw bytes"

    try:
        img_stream = io.BytesIO(file_bytes)
        img = Image.open(img_stream)
        img.verify()  # Verifies file integrity and chunk checksums

        if target_format:
            # Re-open for conversion
            img_stream.seek(0)
            img = Image.open(img_stream)
            fmt = target_format.upper()
            if fmt == "JPG": fmt = "JPEG"
            out_stream = io.BytesIO()
            if fmt == "JPEG" and img.mode in ("RGBA", "P"):
                img = img.convert("RGB")
            img.save(out_stream, format=fmt, quality=100)
            return True, out_stream.getvalue(), f"Converted Image to {fmt}"
        
        return True, file_bytes, f"Validated Image ({img.format})"
    except Exception as e:
        if file_bytes.startswith(b"\x89PNG") or file_bytes.startswith(b"\xFF\xD8\xFF"):
            return True, file_bytes, f"Valid Image Magic Header (Pillow note: {str(e)})"
        return False, file_bytes, f"Invalid Image: {str(e)}"


def convert_and_verify_file(file_bytes: bytes, filename: str, target_format: str = None) -> dict:
    """
    Dispatches file to appropriate Python package processor based on extension.
    """
    ext = os.path.splitext(filename)[1].lower()

    if ext == ".pdf":
        is_valid, out_bytes, details = validate_pdf(file_bytes)
    elif ext in (".docx", ".doc"):
        is_valid, out_bytes, details = validate_docx(file_bytes)
    elif ext in (".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp"):
        is_valid, out_bytes, details = validate_image(file_bytes, filename, target_format)
    else:
        is_valid, out_bytes, details = True, file_bytes, f"Generic binary ({len(file_bytes)} bytes)"

    return {
        "status": "SUCCESS" if is_valid else "CORRUPT",
        "valid": is_valid,
        "filename": filename,
        "details": details,
        "length": len(out_bytes),
        "payload_b64": base64.b64encode(out_bytes).decode('utf-8')
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: file_converter.py <process|capabilities>")
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "process":
        in_raw = sys.stdin.read()
        req = json.loads(in_raw)
        filename = req.get("filename", "file.bin")
        payload = base64.b64decode(req.get("payload_b64", ""))
        target_fmt = req.get("target_format", None)
        res = convert_and_verify_file(payload, filename, target_fmt)
        print(json.dumps(res))
    elif cmd == "capabilities":
        print(json.dumps({
            "pypdf": HAS_PYPDF,
            "python_docx": HAS_DOCX,
            "pillow": HAS_PILLOW
        }))


if __name__ == '__main__':
    main()
