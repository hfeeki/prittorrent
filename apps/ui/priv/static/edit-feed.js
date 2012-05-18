function LightBox() {
    this.el_background = $("<div class='lightboxbackground'></div>");
    this.el = $("<div class='lightbox'></div>");
    this.el_background.append(this.el);
    $('body').append(this.el_background);
}
LightBox.prototype = {
    remove: function() {
	this.el.remove();
	this.el_background.remove();
    },
    find: function(key) {
	return this.el.find(key);
    },
    content: function(contents) {
	this.el.empty();
	this.el.append(contents);
    }
};

/**
 * Edit feed details
 */

var editButton = $("<p class='edit button'>Edit</p>");
$('.meta').after(editButton);
var detailsPath = document.location.pathname + "/details.json";
editButton.bind('click', function() {
    var box = new LightBox();
    box.content('<p>Retrieving...</p>');

    $.ajax({ url: detailsPath,
	     success: function(response) {
		 box.content("<form class='feededit'>" +
			     "<p><input type='checkbox' id='public'> <label for='public'>Public</label> " +
			     "<span class='hint'>Show this feed on your user page and in public listings? You should enable this once everything works.</span></p>" +
			     "<p><input type='checkbox' id='settitle'> <label for='settitle'>Overwrite title</label></p>" +
			     "<p class='titleline'><label for='title'>Title:</label> <input id='title'></p>" +
			     "<p class='cancel button'>Cancel</p>" +
			     "<p class='save button'>Save</p>" +
			     "</form>");
		 box.find('#public').prop('checked', response.public);
		 box.find('#settitle').prop('checked', response.title && response.title.length > 0);
		 box.find('#title').val(response.title);
		 function titleVisibility() {
		     var titleline = box.find('.titleline');
		     if (box.find('#settitle').prop('checked'))
			 titleline.show();
		     else
			 titleline.hide();
		 }
		 box.find('#settitle').bind('change', titleVisibility);
		 titleVisibility();
		 box.find('.cancel').click(box.remove.bind(box));
		 box.find('.save').click(function() {
		     var data = {
			 'public': box.find('#public').prop('checked')
		     };
		     if (box.find('#settitle').prop('checked'))
			 data.title = box.find('#title').val();
		     box.content("<p>Submitting...</p>");
		     $.ajax({ type: 'POST',
			      url: detailsPath,
			      data: data,
			      success: function() {
				  /* Force refresh: */
				  document.location.search = "?" + Math.ceil(Math.random() * 999);
			      },
			      error: function() {
				  box.content("<p>Cannot submit</p>" +
					      "<p class='button'>Close</p>");
				  box.find('.button').click(box.remove.bind(box));
			      }
			    });
		 });
	     },
	     error: function() {
		 box.content("<p>An error occured</p>" +
			     "<p class='button'>Close</p>");
		 box.find('.button').click(box.remove.bind(box));
	     }
	   });
});

/**
 * Remove feed button
 */
var rmButton = $("<p class='add button'>Add</a>");
$('.meta').after(editButton);
rmButton.bind('click', function() {
});
