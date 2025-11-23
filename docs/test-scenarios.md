# Test Scenarios (Local Dev Environment)

Use these scenarios when the dev stack is running (see "Getting Started: Test Environment" in `README-draft.md`).

## 1. Open PDF via Web Library

- [ ] Start the dev stack with sample data.
- [ ] In the Web Library UI (`http://localhost:8281` by default), navigate to an item corresponding to `SAMPLE1`.
- [ ] Trigger the "Open PDF" action for that item.
- [ ] Confirm that the browser loads the PDF via the proxy (URL should include `/pdf/SAMPLE1`).

## 2. Direct PDF Proxy Access

- [ ] Open `http://localhost:8280/pdf/SAMPLE1` directly.
- [ ] Confirm that the sample PDF is rendered or downloaded.
- [ ] Repeat with `SAMPLE2` to verify handling of PDFs nested within subdirectories inside the zip.

## 3. Missing Zip / 404 Behavior

- [ ] Request a non-existent key, e.g. `http://localhost:8280/pdf/UNKNOWN_KEY`.
- [ ] Confirm that the proxy returns an HTTP 404 status and a reasonable error message.

## 4. No PDF in Zip (Future Fixture)

- [ ] (Optional) Add a sample zip without any PDFs using the generator script or manual zip creation.
- [ ] Request that key via `/pdf/{key}`.
- [ ] Confirm that the proxy returns a 404 (or appropriate error code) and that the Web Library UI surfaces a clear error.

