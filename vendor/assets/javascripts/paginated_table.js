(function($) {
  $(document).ready(function() {
    $("div.paginated_table a[data-remote='true']").live('ajax:success', function(event, data, status, xhr) {
      $(this).parents('div.paginated_table').replaceWith(xhr.responseText);
    });
  });
})(jQuery);
