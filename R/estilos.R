# Estilos y barra superior del libro, escritos desde R.
#
# _output.yml llama a escribir_estilos() (con !expr) al construir el libro: los estilos (CSS) y la
# cabecera (favicon, modo oscuro por defecto, barra superior con los iconos del Jupyter Book, pie de
# página y pestañas del paper) se generan en la carpeta _estilos/, que no se versiona.

ESTILOS_COMPONENTES <- r"---[
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500&family=IBM+Plex+Mono:wght@400&display=swap');

/* ============================================================
   Telco Customer Churn — Componentes de salida de los notebooks
   Tablas, indicadores y paneles agrupados (gráfica/tabla +
   interpretación). Usa la paleta de las figuras del libro:
   #1B4F72 (principal), #06B6D4 (acento), #E4572E (riesgo).
   ============================================================ */

:root {

  --tc-navy: #1B4F72;

  --tc-accent: #06B6D4;

  --tc-chip-bg: #EAF2F8;

  --tc-shadow: 0 2px 12px rgba(27, 79, 114, 0.08);

  --tc-font: 'IBM Plex Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;

  --tc-mono: 'IBM Plex Mono', SFMono-Regular, Menlo, monospace;

  --tc-card-bg: #FFFFFF;

  --tc-card-border: #DCE6ED;

  --tc-row-alt: #F4F8FB;

  --tc-text: #243B53;

  --tc-muted: #5B6B7C;
}




/* ---------- Tablas (mismo diseño de las tablas del EDA) ---------- */

.eda-table {

  overflow: auto;

  margin: 12px 0 18px;

  max-width: 100%;

  color: var(--tc-text);

  background: var(--tc-card-bg);

  border: 1px solid var(--tc-card-border);

  border-radius: 8px;

  padding: 12px;

  box-shadow: var(--tc-shadow);
}


.eda-table table {

  display: table !important;

  width: 100%;

  border-collapse: collapse;

  box-shadow: none;

  margin: 0;

  font: 13px/1.5 var(--tc-font);

  background: transparent;
}


.eda-table th {

  background: var(--tc-navy) !important;

  color: #FFFFFF !important;

  padding: 9px !important;

  text-align: left !important;

  cursor: pointer;

  white-space: nowrap;

  font-weight: 500;
}


.eda-table td {

  padding: 8px !important;

  border-bottom: 1px solid var(--tc-card-border);

  white-space: normal !important;

  min-width: 65px;

  max-width: 420px;

  text-align: left !important;

  color: var(--tc-text);

  background: transparent;
}


.eda-table tbody tr,
.eda-table tbody tr:hover {

  background: var(--tc-card-bg) !important;
}


.eda-table tbody td {

  color: var(--tc-text) !important;
}


.eda-table tbody tr:nth-child(even) td {

  background: var(--tc-row-alt) !important;
}


.eda-table input {

  padding: 7px 10px;

  border: 1px solid var(--tc-card-border);

  border-radius: 6px;

  margin: 8px 0;

  color: var(--tc-text);

  background: var(--tc-card-bg);

  font: 13px var(--tc-font);
}


.eda-table-title,
.tc-title {

  display: block;

  color: var(--tc-navy);

  font-size: 0.95rem;

  font-weight: 500;

  letter-spacing: 0.01em;
}




.eda-table-note {

  margin: 8px 2px 0;

  color: var(--tc-muted);

  font-size: 0.82rem;
}


/* ---------- Tarjetas de indicadores ---------- */

.tc-card {

  background: var(--tc-card-bg);

  border: 1px solid var(--tc-card-border);

  border-radius: 8px;

  padding: 14px 16px;

  margin: 12px 0 18px;

  color: var(--tc-text);

  box-shadow: var(--tc-shadow);

  font-family: var(--tc-font);
}


.tc-kpis {

  display: grid;

  grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));

  gap: 10px;

  margin-top: 10px;
}


.tc-kpi {

  min-width: 0;

  background: var(--tc-row-alt);

  border: 1px solid var(--tc-card-border);

  border-top: 3px solid var(--tc-accent);

  border-radius: 8px;

  padding: 10px 12px;
}


.tc-kpi-label {

  display: block;

  color: var(--tc-muted);

  font-size: 0.8rem;

  line-height: 1.35;
}


.tc-kpi-value {

  display: block;

  color: var(--tc-navy);

  font-family: var(--tc-mono);

  font-size: 1.05rem;

  margin-top: 4px;

  overflow-wrap: anywhere;

  word-break: break-word;

  font-variant-numeric: tabular-nums;
}




.tc-kpi-detail {

  display: block;

  color: var(--tc-muted);

  font-size: 0.78rem;

  margin-top: 2px;
}


.tc-note {

  display: flex;

  gap: 10px;

  align-items: flex-start;

  background: var(--tc-row-alt);

  border: 1px solid var(--tc-card-border);

  border-left: 4px solid var(--tc-accent);

  border-radius: 8px;

  padding: 10px 14px;

  margin: 10px 0;

  color: var(--tc-text);

  font-size: 0.92rem;
}


.tc-note.ok {

  border-left-color: #16A34A;
}


.tc-note.warn {

  border-left-color: #F59E0B;
}


.tc-chips {

  display: flex;

  flex-wrap: wrap;

  gap: 6px;

  margin: 6px 0 2px;
}


.tc-chip {

  display: inline-block;

  padding: 2px 10px;

  border-radius: 999px;

  background: var(--tc-chip-bg);

  border: 1px solid var(--tc-card-border);

  color: var(--tc-text);

  font-family: var(--tc-mono);

  font-size: 0.8rem;
}


.tc-kv {

  display: grid;

  grid-template-columns: minmax(150px, max-content) 1fr;

  gap: 6px 16px;

  margin-top: 10px;

  font-size: 0.9rem;
}


.tc-kv dt {

  color: var(--tc-muted);

  font-family: var(--tc-mono);

  font-size: 0.82rem;
}


.tc-kv dd {

  margin: 0;

  color: var(--tc-text);

  word-break: break-word;
}


.tc-card details summary {

  cursor: pointer;

  color: var(--tc-navy);

  font-size: 0.92rem;
}




/* ---------- Paneles agrupados (gráfica / tabla + interpretación) ---------- */

.tc-group {

  background: var(--tc-card-bg);

  border: 1px solid var(--tc-card-border);

  border-radius: 10px;

  margin: 16px 0 26px;

  box-shadow: var(--tc-shadow);

  color: var(--tc-text);

  font-family: var(--tc-font);

  overflow: hidden;
}


.tc-group-head {

  display: flex;

  flex-wrap: wrap;

  gap: 10px 16px;

  align-items: center;

  justify-content: space-between;

  padding: 12px 16px;

  background: var(--tc-row-alt);

  border-bottom: 1px solid var(--tc-card-border);
}


.tc-group-heading {

  display: flex;

  flex-direction: column;

  min-width: 0;
}


.tc-group-kicker {

  color: var(--tc-muted);

  font-size: 0.72rem;

  letter-spacing: 0.08em;

  text-transform: uppercase;
}


.tc-group-current {

  color: var(--tc-navy);

  font-size: 1.1rem;

  font-weight: 500;
}




.tc-group-nav {

  display: flex;

  align-items: center;

  gap: 6px;
}


.tc-select {

  appearance: none;

  -webkit-appearance: none;

  min-width: 220px;

  max-width: 100%;

  padding: 8px 34px 8px 12px;

  border: 1px solid var(--tc-card-border);

  border-radius: 6px;

  color: var(--tc-text);

  font: 0.92rem var(--tc-font);

  cursor: pointer;

  background:
    var(--tc-card-bg)
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' fill='none' stroke='%2306B6D4' stroke-width='2'/%3E%3C/svg%3E")
    no-repeat right 12px center;
}


.tc-step {

  width: 34px;

  height: 34px;

  border: 1px solid var(--tc-card-border);

  border-radius: 6px;

  background: var(--tc-card-bg);

  color: var(--tc-navy);

  font-size: 1.1rem;

  line-height: 1;

  cursor: pointer;
}


.tc-step:hover,
.tc-select:hover {

  border-color: var(--tc-accent);
}


.tc-pane {

  display: none;

  padding: 14px 16px 16px;
}


.tc-pane.is-active {

  display: block;
}


.tc-views {

  display: flex;

  flex-wrap: wrap;

  gap: 8px;

  margin-bottom: 12px;
}


.tc-view-btn {

  padding: 6px 14px;

  border-radius: 999px;

  border: 1px solid var(--tc-navy);

  background: transparent;

  color: var(--tc-navy);

  font: 0.88rem var(--tc-font);

  cursor: pointer;

  transition: background-color 0.15s ease, color 0.15s ease;
}




.tc-view-btn.is-active {

  background: var(--tc-navy);

  border-color: var(--tc-navy);

  color: #FFFFFF;
}


.tc-view {

  display: none;
}


.tc-view.is-active {

  display: block;
}


.tc-intro p,
.tc-interp-body p {

  margin: 0 0 0.6rem;

  color: var(--tc-text);
}


.tc-intro {

  margin-bottom: 8px;

  font-size: 0.95rem;
}


.tc-interp {

  margin-top: 12px;

  padding: 12px 16px;

  background: var(--tc-row-alt);

  border: 1px solid var(--tc-card-border);

  border-left: 4px solid var(--tc-accent);

  border-radius: 8px;
}


.tc-interp-title {

  color: var(--tc-navy);

  font-size: 1rem;

  font-weight: 500;

  margin-bottom: 6px;
}




.tc-interp-body {

  font-size: 0.95rem;
}


.tc-interp-body p:last-child,
.tc-intro p:last-child {

  margin-bottom: 0;
}


.tc-group .eda-table {

  box-shadow: none;
}


@media (max-width: 768px) {

  .tc-select {

    min-width: 0;

    width: 100%;
  }


  .tc-group-nav {

    width: 100%;
  }


  .tc-kv {

    grid-template-columns: 1fr;
  }
}
]---"

ESTILOS_LIBRO <- r"---[
/* ============================================================
   Telco Customer Churn — Apariencia del libro
   Replica el diseño del Jupyter Book (sphinx-book-theme):
   logo en la barra lateral, barra superior con iconos,
   índice "Contents" a la derecha y modo claro/oscuro.
   ============================================================ */

:root {

  --jb-bg: #FFFFFF;

  --jb-text: #222832;

  --jb-heading: #29313D;

  --jb-muted: #48566B;

  --jb-border: #D1D5DA;

  --jb-link: #579ACA;

  --jb-code-bg: #F3F4F5;

  --jb-code-text: #48566B;

  --jb-block-bg: #FEFEFE;

  --jb-fold-bg: #F7F7F7;

  --jb-quote-bg: #F3F4F5;

  --jb-quote-border: #677384;
}


html[data-theme="dark"] {

  --jb-bg: #14181E;

  --jb-text: #CED6DD;

  --jb-heading: #F3F4F5;

  --jb-muted: #9CA4AF;

  --jb-border: #48566B;

  --jb-code-bg: #29313D;

  --jb-code-text: #9CA4AF;

  --jb-block-bg: #2B2B2B;

  --jb-fold-bg: #1E242C;

  --jb-quote-bg: #29313D;

  --jb-quote-border: #9CA4AF;
}


/* ---------- Base ---------- */

html,
body {

  background: var(--jb-bg) !important;

  color: var(--jb-text);

  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", Arial, sans-serif;

  font-size: 16px;
}


main h1,
main h2,
main h3,
main h4,
main h5 {

  color: var(--jb-heading);

  font-weight: 500;
}


main h1 {

  font-size: 2.5rem;

  margin-top: 1.5rem;
}


main h2 {

  font-size: 2rem;
}


main h3 {

  font-size: 1.75rem;
}


main h4 {

  font-size: 1.5rem;
}


main p,
main li,
main td {

  color: var(--jb-text);
}


main a {

  color: var(--jb-link);
}


main :not(pre) > code {

  color: var(--jb-code-text);

  background: var(--jb-code-bg);

  border: 1px solid var(--jb-border);

  border-radius: 4px;

  padding: 0.1rem 0.25rem;

  font-size: 0.875rem;
}


/* Código en línea dentro de tablas, tarjetas y paneles (fondo claro en ambos modos) */

main .tc-group code,
main .eda-table code,
main .tc-card code {

  color: #48566B;

  background: #F3F4F5;

  border-color: #D1D5DA;
}


main blockquote {

  background: var(--jb-quote-bg);

  border-left: 4px solid var(--jb-quote-border);

  color: var(--jb-muted);

  padding: 0.75rem 1rem;
}


main blockquote p {

  color: var(--jb-muted);
}


/* Tablas Markdown (diccionario, paper y guía) */

main table:not(.dataframe) th,
main table:not(.dataframe) td {

  border-color: var(--jb-border);

  color: var(--jb-text);
}


/* ---------- Barra lateral izquierda ---------- */

.sidebar-book {

  background: var(--jb-bg);

  border-right: 1px solid var(--jb-border);
}


.sidebar-book h1 a {

  display: block;
}


.sidebar-book h1 img.tc-logo {

  width: 100%;

  max-width: 230px;

  height: auto;

  margin: 0.5rem 0 1.5rem;
}


.sidebar-book nav > h2,
.sidebar-book .book-extra,
.sidebar-book .book-toc > li:first-child {

  display: none;
}


.sidebar-book .book-toc a {

  display: block;

  color: var(--jb-text);

  font-size: 0.9rem;

  padding: 0.25rem 0.5rem;

  border-left: 3px solid transparent;
}


.sidebar-book .book-toc a:hover {

  color: var(--jb-link);

  text-decoration: underline;
}


.sidebar-book .book-toc a.active {

  color: var(--jb-link) !important;

  font-weight: 600;

  border-left-color: var(--jb-link);
}


.sidebar-book form[role="search"] {

  display: none;
}


.sidebar-book.tc-buscando form[role="search"] {

  display: block;
}


.sidebar-book #search {

  background: var(--jb-bg);

  color: var(--jb-text);

  border-color: var(--jb-border);
}


/* ---------- Barra superior ---------- */

.tc-topbar {

  display: flex;

  align-items: center;

  justify-content: space-between;

  height: 3rem;

  margin: 0 -15px 0.5rem;

  padding: 0 0.5rem;

  position: sticky;

  top: 0;

  z-index: 10;

  background: var(--jb-bg);
}


.tc-topbar-group {

  display: flex;

  gap: 0.35rem;
}


.tc-icono {

  display: inline-flex;

  align-items: center;

  justify-content: center;

  width: 2.25rem;

  height: 2.25rem;

  border: 0;

  border-radius: 6px;

  background: transparent;

  color: var(--jb-muted);

  cursor: pointer;
}


.tc-icono:hover {

  color: var(--jb-link);

  background: var(--jb-code-bg);
}


.tc-icono svg {

  width: 1.25rem;

  height: 1.25rem;

  fill: currentColor;
}


body.tc-sin-lateral .sidebar-book {

  display: none !important;
}


/* ---------- Índice derecho ("Contents") ---------- */

.sidebar-chapter {

  background: var(--jb-bg);
}


.sidebar-chapter #toc {

  border-left: 1px solid var(--jb-border);

  padding-left: 1rem;
}


.sidebar-chapter #toc > h2 {

  color: var(--jb-text);

  font-size: 0.9rem;

  font-weight: 400;
}


.sidebar-chapter #toc > h2::before {

  content: "☰";

  margin-right: 0.35rem;
}


.sidebar-chapter #toc > ul > li:first-child,
.sidebar-chapter .book-extra {

  display: none;
}


.sidebar-chapter .nav-link {

  color: var(--jb-muted);

  font-size: 0.9rem;
}


.sidebar-chapter .nav-link:hover,
.sidebar-chapter .nav-link.active {

  color: var(--jb-link) !important;

  background: transparent !important;
}


/* ---------- Código plegable ("Show code cell source") ---------- */

details.code-fold {

  margin: 1rem 0 0.5rem;
}


details.code-fold > summary {

  list-style: none;

  cursor: pointer;

  background: var(--jb-fold-bg);

  border-left: 3px solid var(--jb-link);

  border-bottom: 1px dashed #CCCCCC;

  color: var(--jb-text);

  padding: 0.15rem 0 0.15rem 1rem;

  font-size: 1rem;
}


details.code-fold > summary::-webkit-details-marker {

  display: none;
}


details.code-fold > summary::before {

  content: "▶";

  font-size: 0.75rem;

  margin-right: 0.6rem;

  display: inline-block;

  transition: transform 0.15s ease;
}


details.code-fold[open] > summary::before {

  transform: rotate(90deg);
}


details.code-fold[open] > summary {

  margin-bottom: 0.5rem;
}


main div.sourceCode {

  background: var(--jb-block-bg) !important;

  border: 1px solid var(--jb-border);

  border-radius: 4px;

  max-width: 100%;

  overflow-x: auto;

  margin: 0 0 1rem;
}


main div.sourceCode pre.sourceCode {

  background: transparent !important;

  border: 0;

  margin: 0;

  max-width: none;

  overflow: visible;
}


main pre code {

  color: var(--jb-text);
}


/* ---------- Salidas de las celdas ---------- */

.cell-output {

  margin: 0.5rem 0 1.5rem;

  max-width: 100%;

  overflow-x: auto;
}


.cell-output img {

  max-width: 100%;

  height: auto;

  background: #FFFFFF;
}


.salida-texto {

  background: var(--jb-block-bg);

  color: var(--jb-text);

  border: 1px solid var(--jb-border);

  padding: 0.75rem 1rem;
}


/* ---------- Tarjetas de la portada ---------- */

.tc-card-grid {

  display: grid;

  gap: 0.5rem;

  margin: 1rem 0 1.5rem;
}


.tc-card-grid.tc-cols-3 {

  grid-template-columns: repeat(3, minmax(0, 1fr));
}


.tc-card-grid.tc-cols-2 {

  grid-template-columns: repeat(2, minmax(0, 1fr));
}


.tc-card-item {

  border: 1px solid var(--jb-border);

  border-radius: 4px;

  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.15);

  padding: 1rem;

  background: var(--jb-bg);
}


.tc-card-title {

  color: var(--jb-text);

  font-weight: 700;

  margin-bottom: 0.75rem;
}


.tc-card-body {

  color: var(--jb-text);
}


@media (max-width: 768px) {

  .tc-card-grid.tc-cols-3,
  .tc-card-grid.tc-cols-2 {

    grid-template-columns: 1fr;
  }
}


/* ---------- Avisos (admonitions) ---------- */

.callout {

  border: 1px solid var(--jb-border);

  border-left: 4px solid #0D6EFD;

  border-radius: 4px;

  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.15);

  margin: 1.5rem 0;

  padding: 0 1rem 0.75rem;

  background: var(--jb-bg);
}


.callout .callout-title {

  display: block;

  margin: 0 -1rem 0.75rem;

  padding: 0.5rem 1rem;

  font-weight: 700;

  background: rgba(13, 110, 253, 0.1);

  color: var(--jb-heading);
}


.callout-warning {

  border-left-color: #FF9100;
}


.callout-warning .callout-title {

  background: rgba(255, 145, 0, 0.1);
}


.callout-tip {

  border-left-color: #00C852;
}


.callout-tip .callout-title {

  background: rgba(0, 200, 82, 0.1);
}


.callout-seealso {

  border-left-color: #00BFA5;
}


.callout-seealso .callout-title {

  background: rgba(0, 191, 165, 0.1);
}


/* ---------- Botón y pestañas del paper ---------- */

.tc-boton {

  margin: 0.5rem 0 1rem;

  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.2);
}


.tc-tabs {

  margin: 1rem 0;

  border-bottom: 1px solid var(--jb-border);
}


.tc-tab-bar {

  display: flex;

  gap: 0.25rem;

  border-bottom: 1px solid var(--jb-border);
}


.tc-tab-btn {

  border: 0;

  border-bottom: 2px solid transparent;

  background: transparent;

  color: var(--jb-muted);

  padding: 0.5rem 1rem;

  cursor: pointer;
}


.tc-tab-btn.is-active {

  color: var(--jb-link);

  border-bottom-color: var(--jb-link);
}


.tc-tab-pane {

  display: none;

  padding: 1rem 0;
}


.tc-tab-pane.is-active {

  display: block;
}


/* ---------- Figuras ---------- */

main .figure,
main figure {

  text-align: center;
}


main .caption,
main figcaption {

  color: var(--jb-text);
}


/* ---------- Pie de página (como en el Jupyter Book) ---------- */

footer.bg-primary {

  display: none !important;
}


.tc-pie {

  margin: 2.5rem 0 1rem;

  padding-top: 1rem;

  border-top: 1px solid var(--jb-border);

  color: var(--jb-muted);

  font-size: 0.9rem;
}


.tc-pie p {

  margin: 0.15rem 0;

  color: var(--jb-muted);
}


main .chapter-nav {

  border-top: 1px solid var(--jb-border);
}


main .chapter-nav .prev,
main .chapter-nav .next {

  border-color: var(--jb-border) !important;

  border-radius: 4px;
}


main .chapter-nav a {

  color: var(--jb-link);
}
]---"

CABECERA <- r"---[
<link rel="icon" href="Imagenes/favicon.ico">
<script>
  /* Modo oscuro por defecto, como en el Jupyter Book; la preferencia queda guardada. */
  (function () {
    var tema = 'dark';
    try { tema = localStorage.getItem('tc-tema') || 'dark'; } catch (e) {}
    document.documentElement.setAttribute('data-theme', tema);
  })();
</script>
<script>
  document.addEventListener('DOMContentLoaded', function () {
    var iconos = {
      menu: '<svg viewBox="0 0 448 512"><path d="M0 96c0-17.7 14.3-32 32-32h384c17.7 0 32 14.3 32 32s-14.3 32-32 32H32c-17.7 0-32-14.3-32-32zm0 160c0-17.7 14.3-32 32-32h384c17.7 0 32 14.3 32 32s-14.3 32-32 32H32c-17.7 0-32-14.3-32-32zm448 160c0 17.7-14.3 32-32 32H32c-17.7 0-32-14.3-32-32s14.3-32 32-32h384c17.7 0 32 14.3 32 32z"/></svg>',
      descarga: '<svg viewBox="0 0 512 512"><path d="M288 32c0-17.7-14.3-32-32-32s-32 14.3-32 32v242.7l-73.4-73.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3l128 128c12.5 12.5 32.8 12.5 45.3 0l128-128c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L288 274.7V32zM64 352c-35.3 0-64 28.7-64 64v32c0 35.3 28.7 64 64 64h384c35.3 0 64-28.7 64-64v-32c0-35.3-28.7-64-64-64H346.5l-45.3 45.3c-25 25-65.5 25-90.5 0L165.5 352H64z"/></svg>',
      pantalla: '<svg viewBox="0 0 448 512"><path d="M32 32C14.3 32 0 46.3 0 64v96c0 17.7 14.3 32 32 32s32-14.3 32-32V96h64c17.7 0 32-14.3 32-32s-14.3-32-32-32H32zm32 320c0-17.7-14.3-32-32-32S0 334.3 0 352v96c0 17.7 14.3 32 32 32h96c17.7 0 32-14.3 32-32s-14.3-32-32-32H64v-64zM320 32c-17.7 0-32 14.3-32 32s14.3 32 32 32h64v64c0 17.7 14.3 32 32 32s32-14.3 32-32V64c0-17.7-14.3-32-32-32h-96zm128 320c0-17.7-14.3-32-32-32s-32 14.3-32 32v64h-64c-17.7 0-32 14.3-32 32s14.3 32 32 32h96c17.7 0 32-14.3 32-32v-96z"/></svg>',
      tema: '<svg viewBox="0 0 512 512"><path d="M448 256c0-106-86-192-192-192v384c106 0 192-86 192-192zm64 0c0 141.4-114.6 256-256 256S0 397.4 0 256 114.6 0 256 0s256 114.6 256 256z"/></svg>',
      buscar: '<svg viewBox="0 0 512 512"><path d="M416 208c0 45.9-14.9 88.3-40 122.7l126.6 126.7c12.5 12.5 12.5 32.8 0 45.3s-32.8 12.5-45.3 0L330.7 376c-34.4 25.2-76.8 40-122.7 40C93.1 416 0 322.9 0 208S93.1 0 208 0s208 93.1 208 208zm-208 144a144 144 0 1 0 0-288 144 144 0 1 0 0 288z"/></svg>'
    };

    /* Logo en la barra lateral, en lugar del título del libro. */
    var titulo = document.querySelector('.sidebar-book h1 a');
    if (titulo) {
      titulo.setAttribute('title', titulo.textContent.trim());
      titulo.innerHTML = '<img class="tc-logo" src="Imagenes/logo.png" alt="' + titulo.textContent.trim() + '">';
    }

    /* Barra superior con los mismos iconos del Jupyter Book. */
    var main = document.querySelector('main');
    if (!main) return;
    var fuente = document.querySelector('#book-source');
    var barra = document.createElement('div');
    barra.className = 'tc-topbar';
    barra.innerHTML =
      '<div class="tc-topbar-group"><button class="tc-icono" data-accion="menu" title="Toggle primary sidebar" aria-label="Toggle primary sidebar">' + iconos.menu + '</button></div>' +
      '<div class="tc-topbar-group">' +
      (fuente ? '<a class="tc-icono" href="' + fuente.href.replace('/blob/', '/raw/') + '" title="Download source file" aria-label="Download source file">' + iconos.descarga + '</a>' : '') +
      '<button class="tc-icono" data-accion="pantalla" title="Fullscreen mode" aria-label="Fullscreen mode">' + iconos.pantalla + '</button>' +
      '<button class="tc-icono" data-accion="tema" title="Light/Dark" aria-label="Light/Dark">' + iconos.tema + '</button>' +
      '<button class="tc-icono" data-accion="buscar" title="Search" aria-label="Search">' + iconos.buscar + '</button>' +
      '</div>';
    main.insertBefore(barra, main.firstChild);

    barra.addEventListener('click', function (evento) {
      var boton = evento.target.closest('button[data-accion]');
      if (!boton) return;
      var accion = boton.getAttribute('data-accion');
      if (accion === 'menu') document.body.classList.toggle('tc-sin-lateral');
      if (accion === 'pantalla') {
        if (document.fullscreenElement) document.exitFullscreen();
        else document.documentElement.requestFullscreen();
      }
      if (accion === 'tema') {
        var nuevo = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        document.documentElement.setAttribute('data-theme', nuevo);
        try { localStorage.setItem('tc-tema', nuevo); } catch (e) {}
      }
      if (accion === 'buscar') {
        var lateral = document.querySelector('.sidebar-book');
        document.body.classList.remove('tc-sin-lateral');
        lateral.classList.toggle('tc-buscando');
        var campo = document.getElementById('search');
        if (campo && lateral.classList.contains('tc-buscando')) campo.focus();
      }
    });

    /* Crédito al pie de cada página, como en el Jupyter Book. */
    var pie = document.createElement('div');
    pie.className = 'tc-pie';
    pie.innerHTML = '<p>By Laura S. Rivera Figueredo y Natal&yacute; A. C&aacute;rdenas Izaquita</p><p>&copy; Copyright 2022.</p>';
    main.appendChild(pie);

    /* Índice derecho con el mismo encabezado del Jupyter Book. */
    var indice = document.querySelector('#toc > h2');
    if (indice) indice.textContent = 'Contents';

    /* Pestañas del paper (Versión web / Versión PDF). */
    document.querySelectorAll('.tc-tabs').forEach(function (grupo) {
      var botones = grupo.querySelectorAll('.tc-tab-btn');
      var paneles = grupo.querySelectorAll('.tc-tab-pane');
      botones.forEach(function (boton, k) {
        boton.addEventListener('click', function () {
          botones.forEach(function (b, j) { b.classList.toggle('is-active', j === k); });
          paneles.forEach(function (p, j) { p.classList.toggle('is-active', j === k); });
        });
      });
    });
  });
</script>
]---"

# Escribe los archivos en _estilos/ y devuelve sus rutas para _output.yml.
escribir_estilos <- function(carpeta = "_estilos") {
  dir.create(carpeta, showWarnings = FALSE)
  rutas <- c(componentes = file.path(carpeta, "componentes.css"), libro = file.path(carpeta, "libro.css"),
             cabecera = file.path(carpeta, "cabecera.html"))
  writeLines(ESTILOS_COMPONENTES, rutas[["componentes"]], useBytes = TRUE)
  writeLines(ESTILOS_LIBRO, rutas[["libro"]], useBytes = TRUE)
  writeLines(CABECERA, rutas[["cabecera"]], useBytes = TRUE)
  list(css = unname(rutas[c("componentes", "libro")]), cabecera = rutas[["cabecera"]])
}

# Al cargar el archivo con source() se escriben los estilos; su valor es la lista de rutas.
escribir_estilos()
