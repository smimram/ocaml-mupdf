#include <mupdf/fitz.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    fz_context *ctx;
    fz_document *doc;
    fz_page *page;
    fz_rect hits[128]; // Array to store results
    int i, n;

    // 1. Initialize the MuPDF context
    ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
    if (!ctx) return 1;

    // Register default document handlers (PDF, XPS, etc.)
    fz_register_document_handlers(ctx);

    // 2. Open the document
    doc = fz_open_document(ctx, "input.pdf");

    // 3. Load the first page (index 0)
    page = fz_load_page(ctx, doc, 0);

    // 4. Search for the text "world"
    // Returns the number of occurrences found (up to the size of our array)
    n = fz_search_page(ctx, page, "world", hits, nelem(hits));

    printf("Found %d occurrences of 'world':\n", n);

    for (i = 0; i < n; i++) {
        printf("Hit %d: x0=%g, y0=%g, x1=%g, y1=%g\n", 
                i, hits[i].x0, hits[i].y0, hits[i].x1, hits[i].y1);
    }

    // 5. Clean up
    fz_drop_page(ctx, page);
    fz_drop_document(ctx, doc);
    fz_drop_context(ctx);

    return 0;
}
