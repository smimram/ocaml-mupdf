#include <mupdf/fitz.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    const char *file_path = "../test.pdf";
    fz_context *ctx = NULL;
    fz_document *doc = NULL;
    fz_buffer *buf = NULL;
    fz_output *out = NULL;
    int page_count, i;

    // 1. Initialisation du contexte
    ctx = fz_new_context(NULL, NULL, FZ_STORE_UNLIMITED);
    if (!ctx)
    {
        fprintf(stderr, "Erreur : impossible de créer le contexte MuPDF\n");
        return EXIT_FAILURE;
    }

    // Enregistrement des types de fichiers supportés (PDF, etc.)
    fz_try(ctx)
        fz_register_document_handlers(ctx);
    fz_catch(ctx)
    {
        fprintf(stderr, "Erreur handlers : %s\n", fz_caught_message(ctx));
        fz_drop_context(ctx);
        return EXIT_FAILURE;
    }

    fz_try(ctx)
    {
        // 2. Ouverture du document
        doc = fz_open_document(ctx, file_path);
        page_count = fz_count_pages(ctx, doc);

        // 3. Préparation du buffer mémoire pour stocker le texte final
        buf = fz_new_buffer(ctx, 2048);
        out = fz_new_output_with_buffer(ctx, buf);

        // 4. Boucle sur les pages
        for (i = 0; i < page_count; i++)
        {
            fz_page *page = fz_load_page(ctx, doc, i);
            fz_rect bbox = fz_bound_page(ctx, page);
            
            // Création d'une structure pour recevoir le texte de la page
            fz_stext_page *text_page = fz_new_stext_page(ctx, bbox);
            fz_device *dev = fz_new_stext_device(ctx, text_page, NULL);

            fz_try(ctx)
            {
                // Extraction du texte par "rendu" virtuel
                fz_run_page(ctx, page, dev, fz_identity, NULL);
                fz_close_device(ctx, dev);

                // Écriture du texte de la page dans notre buffer via le stream 'out'
                fz_print_stext_page_as_text(ctx, out, text_page);
            }
            fz_always(ctx)
            {
                fz_drop_device(ctx, dev);
                fz_drop_stext_page(ctx, text_page);
                fz_drop_page(ctx, page);
            }
            fz_catch(ctx)
            {
                fz_rethrow(ctx);
            }
        }

        // 5. Finalisation de la chaîne de caractères
        fz_terminate_buffer(ctx, buf);

        // Récupération du pointeur vers la chaîne finale
        unsigned char *final_string;
        size_t total_len = fz_buffer_storage(ctx, buf, &final_string);

        printf("--- Début du texte extrait (%zu octets) ---\n", total_len);
        printf("%s\n", (char *)final_string);
        printf("--- Fin du texte ---\n");
    }
    fz_catch(ctx)
    {
        fprintf(stderr, "Erreur lors du traitement : %s\n", fz_caught_message(ctx));
    }

    // 6. Nettoyage final
    fz_drop_output(ctx, out);
    fz_drop_buffer(ctx, buf);
    fz_drop_document(ctx, doc);
    fz_drop_context(ctx);

    return EXIT_SUCCESS;
}
