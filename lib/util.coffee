class Util
  @minAgo: (min, date=null) ->
    date = new Date() unless date
    new Date(date.getTime() - min*60*1000)

  @scaffolds: (params) ->
    $body = $('#nc')
    $body.html('') # remove contents for SEO
    for param in params
      attr = null
      if typeof(param) == 'object'
        id = param[0]
        attr = param[1]
        console.log attr.is_row
      else
        id = param
      $item = $('<div></div>')
      $item.attr('id', id)
      unless (attr && attr.is_row == false)
        $item.addClass('row')
      if attr && attr.is_hide == true
        $item.hide()
      $body.append($item)

  @time: (mtime) ->
    if mtime < 24 * 3600 * 1000
      time = parseInt(mtime/1000)
      min = parseInt(time/60)
      if min > 60
        hour = parseInt(min/60)
        min = min - hour*60
        sec = time - hour*60*60 - min*60
      else
        sec = time - min*60
      if hour
        "#{Util.zero(hour)}:#{Util.zero(min)}:#{Util.zero(sec)}"
      else
        "#{Util.zero(min)}:#{Util.zero(sec)}"
    else
      time = new Date(mtime * 1000)
      month = time.getMonth() + 1
      day  = time.getDate()
      hour = time.getHours()
      min  = time.getMinutes()
      "#{Util.zero(month)}/#{Util.zero(day)} #{Util.zero(hour)}:#{Util.zero(min)}"

  @monthDay: (time) ->
    date = new Date(time)
    month = date.getMonth() + 1
    day  = date.getDate()
    "#{Util.zero(month)}月#{Util.zero(day)}日"

  @hourMin: (time) ->
    date = new Date(time)
    hour = date.getHours()
    min  = date.getMinutes()
    "#{Util.zero(hour)}:#{Util.zero(min)}"

  @zero: (i) ->
    return "00" if i < 0
    if i < 10 then "0#{i}" else "#{i}"

  @countDown: (duration, callback='reload', started=null, params={}) ->
    unless started
      started = (new Date()).getTime()
    past = (new Date()).getTime() - started

    if duration > past # yet end
      remain = duration-past
     
      if remain < 8 * 1000 && remain >= 7 * 1000
        audio = document.getElementById("hato")
        if audio
          audio.play()

      remain2 = Util.time(remain)
      if dom = params.dom
        $dom = $(dom)
      else
        $('title').html(remain2)
        $dom = $('.countdown')
      $dom.html("あと#{remain2}")
      if callback == 'reload'
        setTimeout("Util.countDown(#{duration}, null, #{started}, #{JSON.stringify(params)})", 1000)
      else
        setTimeout("Util.countDown(#{duration}, #{callback}, #{started}, #{JSON.stringify(params)})", 1000)
    else # end
      if callback == 'reload'
        location.reload()
      else
        callback()

  @realtime: () ->
    setTimeout("Util.realtime()", 1000)
    for dom in $('.realtime')
      $dom = $(dom)
      diff = parseInt($dom.attr('data-countdown')) - (new Date()).getTime()
      disp = Util.time(diff)
      $(dom).html(disp)

  @parseHttp: (str) ->
    str.replace(/https?:\/\/[\w?=&.\/-;#~%\-+]+(?![\w\s?&.\/;#~%"=\-]*>)/g, (http) ->
      text = http
      text = text.substring(0, 21) + "..." if text.length > 20

      "<a href=\"#{http}\" target=\"_blank\">#{text}</a>"
    )

  @addButton: (id, $dom, text, callback, tooltip=null) ->
    $button = $('<input>')
    if typeof(text) == 'string'
      $button.attr('type', 'submit')
      $button.attr('value', text)
      $button.addClass('btn-default')
    else
      $button.attr('type', 'image')
      $button.attr('src', text[0])
      $button.css('border', 'none')
      $button.attr('onmouseover', "this.src='#{text[1]}'") if text[1]
      $button.attr('onmouseout', "this.src='#{text[0]}'")
    $button.addClass('btn')

    $button.attr('id', id)
    if tooltip
      $button.tooltip({title: tooltip})
    $dom.append($button)
    $button.click(() ->
      callback()
    )
  @beforeunload: (text, flag) ->
    $(window).on("beforeunload", (e)->
      if flag && eval(flag)
        return text
    )

  @tag: (tagname, val=null, attrs=null) ->
    if tagname == 'img'
      $tag = $("<#{tagname} />")
      $tag.attr('src', val) if val
    else if tagname == 'input'
      $tag = $("<#{tagname} />")
      $tag.attr('placeholder', val) if val
    else
      $tag = $("<#{tagname}></#{tagname}>")
      if val
        $tag.html(val)

    if attrs
      for attr of attrs
        $tag.attr(attr, attrs[attr])

    return $tag

  @calendar: (num) ->
    now = new Date()
    year = undefined
    month = undefined
    date = undefined
    dValue = document.getElementById("dValue")
    switch parseInt(num)
      when 0
        year = now.getFullYear()
        month = now.getMonth() + 1
        date = now.getDate()
      when 1
        backMDate = new Date(parseInt(dValue.innerHTML) - 24 * 60 * 60 * 1000 * 1)
        if backMDate.getMonth() is now.getMonth() and backMDate.getFullYear() is now.getFullYear()
          year = now.getFullYear()
          month = now.getMonth() + 1
          date = now.getDate()
        else
          year = backMDate.getFullYear()
          month = backMDate.getMonth() + 1
          date = -1
      when 2
        nextMDate = new Date(parseInt(dValue.innerHTML) + 24 * 60 * 60 * 1000 * 31)
        if nextMDate.getMonth() is now.getMonth() and nextMDate.getFullYear() is now.getFullYear()
          year = now.getFullYear()
          month = now.getMonth() + 1
          date = now.getDate()
        else
          year = nextMDate.getFullYear()
          month = nextMDate.getMonth() + 1
          date = -1
    dValue.innerHTML = (new Date(year, month - 1, 1)).getTime()
    last_date = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
    editMsg = undefined
    last_date[1] = 29  unless (year % 100 is 0) and (year % 400 isnt 0)  if year % 4 is 0  if month is 2
    editMsg = ""
    editMsg += "<TABLE class='table table-borderd' style='width:100%;'><TR><TD colspan='7' align='center'><B><U><FONT size='-1'>" + year + "年" + month + "月</FONT></B></U></TD></TR>\n"
    editMsg += "<TR>" + defTD("日", "red") + defTD("月", "black") + defTD("火", "black") + defTD("水", "black") + defTD("木", "black") + defTD("金", "black") + defTD("土", "blue") + "</TR>\n"
    editMsg += "<TR>"
    dayIndex = 0
    while dayIndex < (new Date(year, month - 1, 1)).getDay()
      editMsg += defTD("&nbsp;", "white")
      dayIndex++
    i = 1
    while i <= last_date[month - 1]
      editMsg += "<TR>"  if i isnt 1 and dayIndex is 0
      if i is date
        editMsg += defTD(i, "orange")
      else
        switch dayIndex
          when 0
            editMsg += defTD(i, "red")
          when 6
            editMsg += defTD(i, "blue")
          else
            editMsg += defTD(i, "black")
      editMsg += "</TR>\n"  if dayIndex is 6
      dayIndex++
      dayIndex %= 7
      i++
    editMsg += "</TR>\n"  unless dayIndex is 7
    editMsg += "</TABLE>\n"
    document.getElementById("carenda").innerHTML = editMsg

defTD = (str, iro) ->
  res = "<TD align='center'><span style='color:#{iro};'>#{str}</span>"
  if parseInt(str) > 0
    res +="<br /><img class=\"icon icon_eAYx93GzJ8 img-thumbnail\" src=\"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xpa1/v/t1.0-1/c32.32.401.401/s50x50/148782_450079083380_6432972_n.jpg?oh=3325de845f373c56010954c6a8962e15&amp;oe=5529C090&amp;__gda__=1428309205_0d4bc0390bbbd9ae026d0ca3ae1bc5b7\">"
  res += "</TD>"
  return res

window.Util = window.Util || Util
