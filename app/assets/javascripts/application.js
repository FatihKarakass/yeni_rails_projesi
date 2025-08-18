//= require rails-ujs
//= require_tree .

// Silme işlemi için onay mesajı
document.addEventListener('DOMContentLoaded', function() {
  // Tüm silme linklerini bul
  var deleteLinks = document.querySelectorAll('a[data-confirm]');
  
  deleteLinks.forEach(function(link) {
    link.addEventListener('click', function(e) {
      var message = this.getAttribute('data-confirm');
      if (!confirm(message)) {
        e.preventDefault();
        return false;
      }
    });
  });
});
