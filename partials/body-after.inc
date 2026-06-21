<script src="scripts/countdown.js"></script>
<script>
// Hide footer/logo when rendered inside the RevealJS speaker-notes receiver iframe
if (window.location.search.includes('receiver') || window.location.hash.includes('receiver')) {
  document.documentElement.classList.add('speaker-receiver');
}
</script>
<style>
html.speaker-receiver .reveal .footer,
html.speaker-receiver .reveal .slide-logo { display: none !important; }
</style>
