/*  WysiHat - WYSIWYG JavaScript framework, version 0.2.1
 *  (c) 2008-2010 Joshua Peek
 *  JQ-WysiHat - jQuery port of WysiHat to run on jQuery
 *  (c) 2010 Scott Williams
 *
 *  WysiHat is freely distributable under the terms of an MIT-style license.
 *--------------------------------------------------------------------------*/
(function ($, window, undefined)
{

var WysiHat = {};

WysiHat.Editor = {
  attach: function($textarea) {
    var $editArea;

    var id = $textarea.attr('id') + '_editor';
    if ($editArea == $('#' + id)) { return $editArea; }

    $editArea = $('<div id="' + id + '" class="editor" contentEditable="true"></div>');

    $editArea.html(WysiHat.Formatting.getBrowserMarkupFrom($textarea.val()));

    $.extend($editArea, WysiHat.Commands);

    $textarea.before($editArea);
    $textarea.hide();


    return $editArea;
  }
};
WysiHat.BrowserFeatures = (function() {
  function createTmpIframe(callback) {
    var frame, frameDocument;

    frame = $('<iframe></iframe>');
    frame.css({
      position: 'absolute',
      left: '-1000px'
    });

    frame.onFrameLoaded(function() {
      if (typeof frame.contentDocument !== 'undefined') {
        frameDocument = frame.contentDocument;
      } else if (typeof frame.contentWindow !== 'undefined' && typeof frame.contentWindow.document !== 'undefined') {
        frameDocument = frame.contentWindow.document;
      }

      frameDocument.designMode = 'on';

      callback(frameDocument);

      frame.remove();
    });

    $(document.body).insert(frame);
  }

  var features = {};

  function detectParagraphType(document) {
    document.body.innerHTML = '';
    document.execCommand('insertparagraph', false, null);

    var tagName;
    element = document.body.childNodes[0];
    if (element && element.tagName)
      tagName = element.tagName.toLowerCase();

    if (tagName == 'div')
      features.paragraphType = "div";
    else if (document.body.innerHTML == "<p><br></p>")
      features.paragraphType = "br";
    else
      features.paragraphType = "p";
  }

  function detectIndentType(document) {
    document.body.innerHTML = 'tab';
    document.execCommand('indent', false, null);

    var tagName;
    element = document.body.childNodes[0];
    if (element && element.tagName)
      tagName = element.tagName.toLowerCase();
    features.indentInsertsBlockquote = (tagName == 'blockquote');
  }

  features.run = function run() {
    if (features.finished) return;

    createTmpIframe(function(document) {
      detectParagraphType(document);
      detectIndentType(document);

      features.finished = true;
    });
  }

  return features;
})();


if (typeof Selection == 'undefined') {
	var Selection = {}
}

$.extend(Selection.prototype, (function() {
	function getNode() {
	  if (this.rangeCount > 0)
	    return this.getRangeAt(0).getNode();
	  else
	    return null;
	}
	
	function selectNode(element) {
	  var range = document.createRange();
	  range.selectNode(element[0]);
	  this.removeAllRanges();
	  this.addRange(range);
	}
	
	return {
	  getNode:    getNode,
	  selectNode: selectNode
	}
})());

$(document).ready(function() {
  function fieldChangeHandler(event, element) {
    var $element = $(element);
    element = $element.get(0);
    var value;

    if ($element.attr('contentEditable') === 'true') {
      value = $element.html();
    }
    value = $element.val();

    if (value && element.previousValue != value) {
      $element.trigger("field:change");
      element.previousValue = value;
    }
  }

  $('input,textarea,*[contenteditable=""],*[contenteditable=true]').keyup(fieldChangeHandler);
});

WysiHat.Commands = (function(window) {

  function boldSelection() {
    this.execCommand('bold', false, null);
  }

  function boldSelected() {
    return this.queryCommandState('bold');
  }

  function underlineSelection() {
    this.execCommand('underline', false, null);
  }

  function underlineSelected() {
    return this.queryCommandState('underline');
  }

  function italicSelection() {
    this.execCommand('italic', false, null);
  }

  function italicSelected() {
    return this.queryCommandState('italic');
  }

  function strikethroughSelection() {
    this.execCommand('strikethrough', false, null);
  }

  function indentSelection() {
    if ($.browser.mozilla) {
      var selection, range, node, blockquote;

      selection = getSelection();
      range     = selection.getRangeAt(0);
      node      = selection.getNode();

      if (range.collapsed) {
        range = document.createRange();
        range.selectNodeContents(node);
        selection.removeAllRanges();
        selection.addRange(range);
      }

      blockquote = $('<blockquote></blockquote>');
      range = selection.getRangeAt(0);
      range.surroundContents(blockquote);
    } else {
      this.execCommand('indent', false, null);
    }
  }

  function outdentSelection() {
    this.execCommand('outdent', false, null);
  }

  function toggleIndentation() {
    if (this.indentSelected()) {
      this.outdentSelection();
    } else {
      this.indentSelection();
    }
  }

  function indentSelected() {
    var node = getSelection().getNode();
    return node.is("blockquote, blockquote *");
  }

  function fontSelection(font) {
    this.execCommand('fontname', false, font);
  }

  function fontSizeSelection(fontSize) {
    this.execCommand('fontsize', false, fontSize);
  }

  function colorSelection(color) {
    this.execCommand('forecolor', false, color);
  }

  function backgroundColorSelection(color) {
    if($.browser.mozilla) {
      this.execCommand('hilitecolor', false, color);
    } else {
      this.execCommand('backcolor', false, color);
    }
  }

  function alignSelection(alignment) {
    this.execCommand('justify' + alignment);
  }

  function alignSelected() {
    var node = getSelection().getNode();
    return $(node).css('textAlign');
  }

  function linkSelection(url) {
    this.execCommand('createLink', false, url);
  }

  function unlinkSelection() {
    var node = getSelection().getNode();
    if (this.linkSelected())
      getSelection().selectNode(node);

    this.execCommand('unlink', false, null);
  }

  function linkSelected() {
    var node = getSelection().getNode();
    return node ? node.get(0).tagName.toUpperCase() == 'A' : false;
  }

  function formatblockSelection(element){
    this.execCommand('formatblock', false, element);
  }

  function toggleOrderedList() {
    var selection, node;

    selection = getSelection();
    node      = selection.getNode();

    if (this.orderedListSelected() && !node.is("ol li:last-child, ol li:last-child *")) {
      selection.selectNode(node.parent("ol"));
    } else if (this.unorderedListSelected()) {
      selection.selectNode(node.parent("ul"));
    }

    this.execCommand('insertorderedlist', false, null);
  }

  function insertOrderedList() {
    this.toggleOrderedList();
  }

  function orderedListSelected() {
    var element = getSelection().getNode();
    if (element) return element.is('*[contenteditable=""] ol, *[contenteditable=true] ol, *[contenteditable=""] ol *, *[contenteditable=true] ol *');
    return false;
  }

  function toggleUnorderedList() {
    var selection, node;

    selection = getSelection();
    node      = selection.getNode();

    if (this.unorderedListSelected() && !node.is("ul li:last-child, ul li:last-child *")) {
      selection.selectNode(node.parent("ul"));
    } else if (this.orderedListSelected()) {
      selection.selectNode(node.parent("ol"));
    }

    this.execCommand('insertunorderedlist', false, null);
  }

  function insertUnorderedList() {
    this.toggleUnorderedList();
  }

  function unorderedListSelected() {
    var element = getSelection().getNode();
    if (element) return element.is('*[contenteditable=""] ul, *[contenteditable=true] ul, *[contenteditable=""] ul *, *[contenteditable=true] ul *');
    return false;
  }

  function insertImage(url) {
    this.execCommand('insertImage', false, url);
  }

  function insertHTML(html) {
    if ($.browser.msie) {
      var range = window.document.selection.createRange();
      range.pasteHTML(html);
      range.collapse(false);
      range.select();
    } else {
      this.execCommand('insertHTML', false, html);
    }
  }

  function execCommand(command, ui, value) {
    var handler = this.commands[command];
    if (handler) {
      handler.bind(this)(value);
    } else {
      try {
        window.document.execCommand(command, ui, value);
      } catch(e) { return null; }
    }

    $(document.activeElement).trigger("field:change");
  }

  function queryCommandState(state) {
    var handler = this.queryCommands[state];
    if (handler) {
      return handler();
    } else {
      try {
        return window.document.queryCommandState(state);
      } catch(e) { return null; }
    }
  }

  function getSelectedStyles() {
    var styles = {};
    var editor = this;
    editor.styleSelectors.each(function(style){
      var node = editor.selection.getNode();
      styles[style.first()] = $(node).css(style.last());
    });
    return styles;
  }

  return {
     boldSelection:            boldSelection,
     boldSelected:             boldSelected,
     underlineSelection:       underlineSelection,
     underlineSelected:        underlineSelected,
     italicSelection:          italicSelection,
     italicSelected:           italicSelected,
     strikethroughSelection:   strikethroughSelection,
     indentSelection:          indentSelection,
     outdentSelection:         outdentSelection,
     toggleIndentation:        toggleIndentation,
     indentSelected:           indentSelected,
     fontSelection:            fontSelection,
     fontSizeSelection:        fontSizeSelection,
     colorSelection:           colorSelection,
     backgroundColorSelection: backgroundColorSelection,
     alignSelection:           alignSelection,
     alignSelected:            alignSelected,
     linkSelection:            linkSelection,
     unlinkSelection:          unlinkSelection,
     linkSelected:             linkSelected,
     formatblockSelection:     formatblockSelection,
     toggleOrderedList:        toggleOrderedList,
     insertOrderedList:        insertOrderedList,
     orderedListSelected:      orderedListSelected,
     toggleUnorderedList:      toggleUnorderedList,
     insertUnorderedList:      insertUnorderedList,
     unorderedListSelected:    unorderedListSelected,
     insertImage:              insertImage,
     insertHTML:               insertHTML,
     execCommand:              execCommand,
     queryCommandState:        queryCommandState,
     getSelectedStyles:        getSelectedStyles,

    commands: {},

    queryCommands: {
      link:          linkSelected,
      orderedlist:   orderedListSelected,
      unorderedlist: unorderedListSelected
    },

    styleSelectors: {
      fontname:    'fontFamily',
      fontsize:    'fontSize',
      forecolor:   'color',
      hilitecolor: 'backgroundColor',
      backcolor:   'backgroundColor'
    }
  };
})(window);


if ($.browser.msie) {
  $.extend(Selection.prototype, (function() {
    function setBookmark() {
      var bookmark = $('#bookmark');
      if (bookmark) bookmark.remove();

      bookmark = $('<span id="bookmark">&nbsp;</span>');
      var parent = $('<div></div>').html(bookmark);

      var range = this._document.selection.createRange();
      range.collapse();
      range.pasteHTML(parent.html());
    }

    function moveToBookmark() {
      var bookmark = $('#bookmark');
      if (!bookmark) return;

      var range = this._document.selection.createRange();
      range.moveToElementText(bookmark);
      range.collapse();
      range.select();

      bookmark.remove();
    }

    return {
      setBookmark:    setBookmark,
      moveToBookmark: moveToBookmark
    }
  })());
} else {
  $.extend(Selection.prototype, (function() {
    function setBookmark() {
      var bookmark = $('#bookmark');
      if (bookmark) bookmark.remove();

      bookmark = $('<span id="bookmark">&nbsp;</span>');
      this.getRangeAt(0).insertNode(bookmark);
    }

    function moveToBookmark() {
      var bookmark = $('#bookmark');
      if (!bookmark) return;

      var range = document.createRange();
      range.setStartBefore(bookmark);
      this.removeAllRanges();
      this.addRange(range);

      bookmark.remove();
    }

    return {
      setBookmark:    setBookmark,
      moveToBookmark: moveToBookmark
    }
  })());
}

(function() {
  function cloneWithAllowedAttributes(element, allowedAttributes) {
    var length = allowedAttributes.length, i;
    var result = $('<' + element.tagName.toLowerCase() + '></' + element.tagName.toLowerCase() + '>')
    element = $(element);

    for (i = 0; i < allowedAttributes.length; i++) {
      attribute = allowedAttributes[i];
      if (element.attr(attribute)) {
        result.attr(attribute, element.attr(attribute));
      }
    }

    return result;
  }

  function withEachChildNodeOf(element, callback) {
    var nodes = $(element).children;
    var length = nodes.length, i;
    for (i = 0; i < length; i++) callback(nodes[i]);
  }

  function sanitizeNode(node, tagsToRemove, tagsToAllow, tagsToSkip) {
    var parentNode = node.parentNode;

    switch (node.nodeType) {
      case Node.ELEMENT_NODE:
        var tagName = node.tagName.toLowerCase();

        if (tagsToSkip) {
          var newNode = node.cloneNode(false);
          withEachChildNodeOf(node, function(childNode) {
            newNode.appendChild(childNode);
            sanitizeNode(childNode, tagsToRemove, tagsToAllow, tagsToSkip);
          });
          parentNode.insertBefore(newNode, node);

        } else if (tagName in tagsToAllow) {
          var newNode = cloneWithAllowedAttributes(node, tagsToAllow[tagName]);
          withEachChildNodeOf(node, function(childNode) {
            newNode.appendChild(childNode);
            sanitizeNode(childNode, tagsToRemove, tagsToAllow, tagsToSkip);
          });
          parentNode.insertBefore(newNode, node);

        } else if (!(tagName in tagsToRemove)) {
          withEachChildNodeOf(node, function(childNode) {
            parentNode.insertBefore(childNode, node);
            sanitizeNode(childNode, tagsToRemove, tagsToAllow, tagsToSkip);
          });
        }

      case Node.COMMENT_NODE:
        parentNode.removeChild(node);
    }
  }

  $.fn.sanitizeContents = function(options) {
    var element = $(this);
    var tagsToRemove = {};
    $.each((options.remove || "").split(","), function(tagName) {
      tagsToRemove[$.trim(tagName)] = true;
    });

    var tagsToAllow = {};
    $.each((options.allow || "").split(","), function(selector) {
      var parts = $.trim(selector).split(/[\[\]]/);
      var tagName = parts[0];
      var allowedAttributes = $.grep(parts.slice(1), function(n, i) {
        return /./.test(n);
      });
      tagsToAllow[tagName] = allowedAttributes;
    });

    var tagsToSkip = options.skip;

    withEachChildNodeOf(element, function(childNode) {
      sanitizeNode(childNode, tagsToRemove, tagsToAllow, tagsToSkip);
    });

    return element;
  }
})();

(function() {
  function onReadyStateComplete(document, callback) {

    function checkReadyState() {
      if (document.readyState === 'complete') {
        $(document).unbind('readystatechange', checkReadyState);
        callback();
        return true;
      } else {
        return false;
      }
    }

    $(document).bind('readystatechange', checkReadyState);
    checkReadyState();
  }

  function observeFrameContentLoaded(element) {
    element = $(element);
    var bare = element.get(0);

    var loaded, contentLoadedHandler;

    loaded = false;
    function fireFrameLoaded() {
      if (loaded) { return };

      loaded = true;
      if (contentLoadedHandler) { contentLoadedHandler.stop(); }
      element.trigger('frame:loaded');
    }

    if (window.addEventListener) {
      contentLoadedHandler = $(document).bind("DOMFrameContentLoaded", function(event) {
        if (element == $(this))
          fireFrameLoaded();
      });
    }

    element.load(function() {
      var frameDocument;
      if (typeof element.contentDocument !== 'undefined') {
        frameDocument = element.contentDocument;
      } else if (typeof element.contentWindow !== 'undefined' && typeof element.contentWindow.document !== 'undefined') {
        frameDocument = element.contentWindow.document;
      }

      onReadyStateComplete(frameDocument, fireFrameLoaded);
    });

    return element;
  }

  function onFrameLoaded($element, callback) {
    $element.bind('frame:loaded', callback);
    $element.observeFrameContentLoaded();
  }

  $.fn.observeFrameContentLoaded = observeFrameContentLoaded;
  $.fn.onFrameLoaded = onFrameLoaded;
})();
$(document).ready(function() {
  var $doc = $(document);
  if ('selection' in document && 'onselectionchange' in document) {
    var selectionChangeHandler = function() {
      var range   = document.selection.createRange();
      var element = range.parentElement();

      $(element).trigger("selection:change");
    }

    $doc.bind("selectionchange", selectionChangeHandler);
  } else {
    var previousRange;

    var selectionChangeHandler = function() {
      var element        = document.activeElement;
      var elementTagName = element.tagName.toLowerCase();

      if (elementTagName == "textarea" || elementTagName == "input") {
        previousRange = null;
        $(element).trigger("selection:change");
      } else {
        var selection = getSelection();
        if (selection.rangeCount < 1) { return };

        var range = selection.getRangeAt(0);
        if (range && range.equalRange(previousRange)) {
          return;
        }
        previousRange = range;

        element = range.commonAncestorContainer;
        while (element.nodeType == Node.TEXT_NODE)
          element = element.parentNode;

        $(element).trigger("selection:change");
      }
    };

    $doc.mouseup(selectionChangeHandler);
    $doc.keyup(selectionChangeHandler);
  }
});

WysiHat.Formatting = (function() {
  var ACCUMULATING_LINE      = {};
  var EXPECTING_LIST_ITEM    = {};
  var ACCUMULATING_LIST_ITEM = {};

  return {
    getBrowserMarkupFrom: function(applicationMarkup) {
      var container = $("<div>" + applicationMarkup + "</div>");

      function spanify(element, style) {
        $(element).replaceWith(
          '<span style="' + style +
          '" class="Apple-style-span">' +
          element.innerHTML + '</span>'
        );
      }

      function convertStrongsToSpans() {
        container.find("strong").each(function(element) {
          spanify(element, "font-weight: bold");
        });
      }

      function convertEmsToSpans() {
        container.find("em").each(function(element) {
          spanify(element, "font-style: italic");
        });
      }

      function convertDivsToParagraphs() {
        container.find("div").each(function(element) {
          element.replaceWith("<p>" + element.innerHTML + "</p>");
        });
      }

      if ($.browser.webkit || $.browser.mozilla) {
        convertStrongsToSpans();
        convertEmsToSpans();
      } else if ($.browser.msie || $.browser.opera) {
        convertDivsToParagraphs();
      }

      return container.innerHTML;
    },

    getApplicationMarkupFrom: function(element) {
      var mode = ACCUMULATING_LINE, result, container, line, lineContainer, previousAccumulation;

      function walk(nodes) {
        var length = nodes.length, node, tagName, i;

        for (i = 0; i < length; i++) {
          node = nodes[i];

          if (node.nodeType == Node.ELEMENT_NODE) {
            tagName = node.tagName.toLowerCase();
            open(tagName, node);
            walk(node.childNodes);
            close(tagName);

          } else if (node.nodeType == Node.TEXT_NODE) {
            read(node.nodeValue);
          }
        }
      }

      function open(tagName, node) {
        if (mode == ACCUMULATING_LINE) {
          if (isBlockElement(tagName)) {
            if (isEmptyParagraph(node)) {
              accumulate($("<br />"));
            }

            flush();

            if (isListElement(tagName)) {
              container = insertList(tagName);
              mode = EXPECTING_LIST_ITEM;
            }

          } else if (isLineBreak(tagName)) {
            if (isLineBreak(getPreviouslyAccumulatedTagName())) {
              previousAccumulation.parentNode.removeChild(previousAccumulation);
              flush();
            }

            accumulate(node.cloneNode(false));

            if (!previousAccumulation.previousNode) flush();

          } else {
            accumulateInlineElement(tagName, node);
          }

        } else if (mode == EXPECTING_LIST_ITEM) {
          if (isListItemElement(tagName)) {
            mode = ACCUMULATING_LIST_ITEM;
          }

        } else if (mode == ACCUMULATING_LIST_ITEM) {
          if (isLineBreak(tagName)) {
            accumulate(node.cloneNode(false));

          } else if (!isBlockElement(tagName)) {
            accumulateInlineElement(tagName, node);
          }
        }
      }

      function close(tagName) {
        if (mode == ACCUMULATING_LINE) {
          if (isLineElement(tagName)) {
            flush();
          }

          if (line != lineContainer) {
            lineContainer = lineContainer.parentNode;
          }

        } else if (mode == EXPECTING_LIST_ITEM) {
          if (isListElement(tagName)) {
            container = result;
            mode = ACCUMULATING_LINE;
          }

        } else if (mode == ACCUMULATING_LIST_ITEM) {
          if (isListItemElement(tagName)) {
            flush();
            mode = EXPECTING_LIST_ITEM;
          }

          if (line != lineContainer) {
            lineContainer = lineContainer.parentNode;
          }
        }
      }

      function isBlockElement(tagName) {
        return isLineElement(tagName) || isListElement(tagName);
      }

      function isLineElement(tagName) {
        return tagName == "p" || tagName == "div";
      }

      function isListElement(tagName) {
        return tagName == "ol" || tagName == "ul";
      }

      function isListItemElement(tagName) {
        return tagName == "li";
      }

      function isLineBreak(tagName) {
        return tagName == "br";
      }

      function isEmptyParagraph(node) {
        return node.tagName.toLowerCase() == "p" && node.childNodes.length == 0;
      }

      function read(value) {
        accumulate(document.createTextNode(value));
      }

      function accumulateInlineElement(tagName, node) {
        var element = node.cloneNode(false);

        if (tagName == "span") {
          if ($(node).getStyle("fontWeight") == "bold") {
            element = $("<strong></strong>");

          } else if ($(node).getStyle("fontStyle") == "italic") {
            element = $("<em></em>");
          }
        }

        accumulate(element);
        lineContainer = element;
      }

      function accumulate(node) {
        if (mode != EXPECTING_LIST_ITEM) {
          if (!line) line = lineContainer = createLine();
          previousAccumulation = node;
          lineContainer.appendChild(node);
        }
      }

      function getPreviouslyAccumulatedTagName() {
        if (previousAccumulation && previousAccumulation.nodeType == Node.ELEMENT_NODE) {
          return previousAccumulation.tagName.toLowerCase();
        }
      }

      function flush() {
        if (line && line.childNodes.length) {
          container.appendChild(line);
          line = lineContainer = null;
        }
      }

      function createLine() {
        if (mode == ACCUMULATING_LINE) {
          return $("<div></div>");
        } else if (mode == ACCUMULATING_LIST_ITEM) {
          return $("<li></li>");
        }
      }

      function insertList(tagName) {
        var list = new Element(tagName);
        result.appendChild(list);
        return list;
      }

      result = container = $("<div></div>");
      walk(element.childNodes);
      flush();
      return result.innerHTML;
    }
  };
})();


WysiHat.Toolbar = function() {
  var editor;
  var element;

  function initialize(ed) {
    editor = ed;
    element = createToolbarElement();
  }

  function createToolbarElement() {
    var toolbar = $('<div class="editor_toolbar"></div>');
    editor.before(toolbar);
    return toolbar;
  }

  function addButtonSet(options) {
    $(options.buttons).each(function(index, button){
      addButton(button);
    });
  }

  function addDropdown(options, handler) {
    if (!options['name']) {
      options['name'] = options['label'].toLowerCase();
    }
    var name = options['name'];
    var select = createDropdownElement(element, options);

    var handler = buttonHandler(name, options);
    observeDropdownChange(select, handler);
  }

  function addButton(options, handler) {
    if (!options['name']) {
      options['name'] = options['label'].toLowerCase();
    }
    var name = options['name'];

    var button = createButtonElement(element, options);

    var handler = buttonHandler(name, options);
    observeButtonClick(button, handler);

    var handler = buttonStateHandler(name, options);
    observeStateChanges(button, name, handler);
  }

  function createButtonElement(toolbar, options) {
    var button = $('<a class="" href="#"><span>' + options['label'] + '</span></a>');
    button.addClass("button");
		button.addClass(options['name']);
		button.addClass(options['cssClass']);
    toolbar.append(button);

    return button;
  }

  function createDropdownElement(toolbar, options) {
    var optionTemplate = '<option value="KEY">VALUE</option>',
        selectTemplate = '<select>OPTIONS</select>';
        builder = '';
    for (var i = 0; i < options.options.length; i++) {
      var o = options.options[i];
      builder += optionTemplate.replace('KEY', o.val).replace('VALUE', o.label);
    };
    var select = $('<select>' + builder + '</select>');
    select.addClass(options['cssClass']);
    toolbar.append(select);
    return select;
  }

  function buttonHandler(name, options) {
    if (options.handler)
      return options.handler;
    else if (options['handler'])
      return options['handler'];
    else
      return function(editor) { editor.execCommand(name); };
  }

  function observeButtonClick(element, handler) {
    $(element).click(function() {
      handler(editor);
      $(document.activeElement).trigger("selection:change");
      return false;
    });
  }

  function observeDropdownChange(element, handler) {
    $(element).change(function() {
      var selectedValue = $(this).val();
      handler(editor, selectedValue);
      $(document.activeElement).trigger("selection:change");
    });
  }

  function buttonStateHandler(name, options) {
    if (options.query)
      return options.query;
    else if (options['query'])
      return options['query'];
    else
      return function(editor) { return editor.queryCommandState(name); };
  }

  function observeStateChanges(element, name, handler) {
    var previousState;
    editor.bind("selection:change", function() {
      var state = handler(editor);
      if (state != previousState) {
        previousState = state;
        updateButtonState(element, name, state);
      }
    });
  }

  function updateButtonState(elem, name, state) {
    if (state)
      $(elem).addClass('selected');
    else
      $(elem).removeClass('selected');
  }

  return {
    initialize:           initialize,
    createToolbarElement: createToolbarElement,
    addButtonSet:         addButtonSet,
    addButton:            addButton,
    addDropdown:          addDropdown,
    createButtonElement:  createButtonElement,
    buttonHandler:        buttonHandler,
    observeButtonClick:   observeButtonClick,
    buttonStateHandler:   buttonStateHandler,
    observeStateChanges:  observeStateChanges,
    updateButtonState:    updateButtonState
  };
};

WysiHat.Toolbar.ButtonSets = {};

WysiHat.Toolbar.ButtonSets.Basic = [
  { label: "Bold" },
  { label: "Underline" },
  { label: "Italic" }
];

WysiHat.Toolbar.ButtonSets.Standard = [
  { label: "Bold", cssClass: 'toolbar_button' },
  { label: "Italic", cssClass: 'toolbar_button' },
  { label: "Strikethrough", cssClass: 'toolbar_button' },
  { label: "Bullets", cssClass: 'toolbar_button', handler: function(editor) { return editor.toggleUnorderedList(); } }
];

$.fn.wysihat = function(options) {
	options = $.extend({
			buttons: WysiHat.Toolbar.ButtonSets.Standard
		}, options);

	return this.each(function() {
		var editor = WysiHat.Editor.attach($(this));
		var toolbar = new WysiHat.Toolbar(editor);
		toolbar.initialize(editor);
		toolbar.addButtonSet(options);
	});
};

window.WysiHat = WysiHat;
}(jQuery, this));
