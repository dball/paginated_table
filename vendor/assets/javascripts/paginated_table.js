(function($) {
  $(document).ready(function() {
    $("div.pagination a[data-remote='true']").live('ajax:success', function(event, data, status, xhr) {
      $(this).parents('div.pagination').replaceWith(xhr.responseText);
    });
  });
})(jQuery);
