$ ->
  ParseParse.addAccesslog()
  Util.scaffolds(['header', 'contents', 'doing', 'done', 'complete', 'comments', 'search', 'footer'])
  ruffnote(13475, 'header')
  ruffnote(13477, 'footer')
  initDoing()
  initDone()
  initStart()

initStart = () ->
  console.log 'initStart'
  window.is_commenting = false
  window.pomotime = 24
  window.sc_client_id = '2b9312964a1619d99082a76ad2d6d8c6'
  $start = $('<input>').attr('type', 'submit').attr('id', 'start')
  if Parse.User.current()
    text = '曲お任せで24分間集中する！！'
  else
    text = 'facebookログイン'
  $start.attr('value', text)
  $start.attr('class', 'btn btn-default')
  $('#contents').html($start)
  $('#start').click(() ->
    start()
  )

initDone = () ->
  console.log 'initDone'
  $("#done").append("<hr />")
  $("#done").append("<h2>DONE</h2>")
  cond = [["is_done", true]]
  ParseParse.where("Workload", cond, (workloads) ->
    date = ""
    for workload in workloads
      continue unless workload.attributes.user
      w = workload.attributes
      i = Util.monthDay(workload.createdAt)
      if date != i
        $("#done").append("<h2>#{i}</h2>")
      date = i

      $("#done").append("""
        #{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<div style=\"display:inline; border: 1px solid #000; padding:20px; text-align:center; vertical-align:middle;\">no image</div>'}
        <img class='icon icon_#{w.user.id}' />
        <span id=\"workload_#{workload.id}\">#{w.number}</span>回目@#{Util.hourMin(workload.createdAt)}<br />
        #{w.title} <br />
        <a href=\"##{w.sc_id}\" class='fixed_start btn btn-default'>この曲で集中する</a>
        <hr />
      """)

      ParseParse.fetch("user", workload, (workload, user) ->
        $(".icon_#{user.id}").attr('src', user.get('icon')._url)
      )

    $('.fixed_start').click(() ->
      if Parse.User.current()
        start($(this).attr('href').replace(/^#/,''))
      else
        alert 'Facebookログインをお願いします！'
    )
  )

initDoing = () ->
  cond = [
    ["is_done", null]
    ["createdAt", '>', Util.minAgo(24)]
  ]
  ParseParse.where("Workload", cond, (workloads) ->
    if workloads.length > 0
      $("#doing").append("<h2>NOW DOING</h2>")

      for workload in workloads
        continue unless workload.attributes.user
        w = workload.attributes
        t = new Date(workload.createdAt)
        i = Util.monthDay(workload.createdAt)
        now = new Date()
        diff = window.pomotime*60*1000 + t.getTime() - now.getTime()

        $("#doing").append("""
          #{if w.artwork_url then '<img src=\"' + w.artwork_url + '\" />' else '<div style=\"display:inline; border: 1px solid #000; padding:20px; text-align:center; vertical-align:middle;\">no image</div>'}
          <img class='icon icon_#{w.user.id}' />
          @#{Util.hourMin(workload.createdAt)}（あと#{Util.time(diff)}）<br />
          #{w.title} <br />
          <a href=\"##{w.sc_id}\" class='fixed_start btn btn-default'>この曲で集中する</a>
          <hr />
        """)

        ParseParse.fetch("user", workload, (workload, user) ->
          $(".icon_#{user.id}").attr('src', user.get('icon')._url)
        )
    )

login = () ->
  console.log 'login'
  window.fbAsyncInit()

start = (sc_id=null, workload=null) ->
  unless Parse.User.current()
    login()
  console.log 'start'
  if localStorage['next_url'] && localStorage['next_url'].length > 1 && localStorage['next_url'].match('^http')
    window.open(localStorage['next_url'], "_blank")
  $("#done").hide()
  $start = $('<div></div>').attr('id', 'playing')
  $('#contents').html($start)
  if sc_id
    play(sc_id, workload)
    return
  if localStorage['sc_id'] == location.hash.replace(/#/, '') || location.hash.length < 1
    ParseParse.all("Music", (musics) ->
      n = Math.floor(Math.random() * musics.length)
      sc_id = musics[n].attributes.sc_id
      location.hash = sc_id
      play()
    )
  else
    play()

play = (sc_id=null, workload=null) ->
  console.log 'play'
  localStorage['sc_id'] = if sc_id then sc_id else location.hash.replace(/#/, '')

  Soundcloud.fetch(localStorage['sc_id'], window.sc_client_id, (track) ->
    if workload #resume
      window.workload = workload
      t = new Date(workload.createdAt)
      now = new Date()
      diff = window.pomotime*60*1000 + t.getTime() - now.getTime()
      Util.countDown(diff, complete)
    else # new
      params = {}
      for key in ['sc_id']
        params[key] = localStorage[key]
      for key in ['title', 'artwork_url']
        params[key] = track[key]
      params['host'] = location.host
      ParseParse.create("Workload", params, (workload) ->
        window.workload = workload
      )

      localStorage['artwork_url'] = track.artwork_url
      Util.countDown(window.pomotime*60*1000, complete)

    ap = if localStorage['is_dev'] then 'false' else 'true'
    $("#playing").html("""
    <iframe width="100%" height="400" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?visual=true&url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F#{localStorage['sc_id']}&show_artwork=true&client_id=#{window.sc_client_id}&auto_play=#{ap}"></iframe>
    """)
  )

complete = () ->
  console.log 'complete'
  $("#playing").fadeOut()
  workload = window.workload
  w = workload.attributes
  first = new Date(workload.createdAt)
  first = first.getTime() - first.getHours()*60*60*1000 - first.getMinutes()*60*1000 - first.getSeconds() * 1000
  first = new Date(first)
  cond = [
    ["is_done", true]
    ['twitter_id', w.twitter_id]
    ["createdAt", '<', workload.createdAt]
    ["createdAt", '>', first]
  ]
  ParseParse.where("Workload", cond, (workload, data) ->
    workload.set('number', data.length + 1)
    workload.set('is_done', true)
    workload.save()
  , workload)

  $complete = $('#complete')
  $complete.html('24分おつかれさまでした！5分間交換ノートが見られます')

  $nextUrl = $('<a></a>').addClass('next_url').html('タスクURLを設定する').attr('href', location.hash)
  $complete.append($nextUrl)

  $nextUrlCancel = $('<a></a>').addClass('next_url_cancel').html('タスクURLを削除する').attr('href', location.hash)
  $nextUrlCancel.hide() if typeof(localStorage['next_url']) == 'undefined'

  $complete.append($nextUrlCancel)

  $comment = $('<input />').attr('id', 'comment')
  $('#complete').append($comment)

  $('.next_url').click(() ->
    nextUrl()
  )
  $('.next_url_cancel').click(() ->
    nextUrlCancel()
  )

  initComments()

  $track = $("<input />").attr('id', 'track')
  $tracks = $("<div></div>").attr('id', 'tracks')

  $('#search').append("<hr /><h3>好きなパワーソングを探す</h3>")
  $('#search').append($track)
  $('#search').append($tracks)

  $('#track').keypress((e) ->
    if e.which == 13 #enter
      q = $('#track').val()
      url = "http://api.soundcloud.com/tracks.json?client_id=#{window.sc_client_id}&q=#{q}&duration[from]=#{19*60*1000}&duration[to]=#{24*60*1000}"
      $.get(url, (tracks) ->
        if tracks[0]
          for track in tracks
            artwork = ''
            if track.artwork_url
              artwork = "<img src=\"#{track.artwork_url}\" width=100px/>"

            $('#tracks').append("""
              <tr>
                <td><a href=\"##{track.id}\">#{track.title}</a></td>
                <td>#{artwork}</td>
                <td>#{Util.time(track.duration)}</td>
              </tr>
            """)
        else
          alert "「#{q}」で24分前後の曲はまだ出てないようです...。他のキーワードで探してみてください！"
      )
  )
  Util.countDown(5*60*1000, 'finish')

window.initComments = () ->
  $recents = $('<table></table>').addClass('table recents')
  $comments = $("#comments")

  ParseParse.where("Comment", [], (comments) ->
    $('#comment').keypress((e) ->
      if e.which == 13 #enter
        body = $('#comment').val()
        window.comment(body) unless window.is_commenting
    )
    for comment in comments
      c = comment.attributes
      t = new Date(comment.createdAt)
      hour = t.getHours()
      min = t.getMinutes()

      if c.user
        $recents.append("""
        <tr>
        <td><img class='icon icon_#{c.user.id}' /><td>
        <td>#{Util.parseHttp(c.body)}</td>
        <td>#{hour}時#{min}分</td>
        </tr>
        """)

        ParseParse.fetch("user", comment, (comment, user) ->
          $(".icon_#{user.id}").attr('src', user.get('icon')._url)
        )
    $comments.html($recents)
    $('#comment').val('')
    $('#comment').focus()
  )

window.nextUrl = () ->
  console.log 'nextUrl'
  content = localStorage['next_url']
  content = 'http://' if !content or content.length < 1
  next_url = prompt("次の作業のURLを入れてください（必ずhttpからはじめてください）", content)
  if next_url != null
    localStorage['next_url'] = next_url
    alert "#{next_url}を次スタートする時に自動で開くように設定しました"
    $('.next_url_cancel').fadeIn()

window.nextUrlCancel = () ->
  console.log 'nextUrlCancel'
  localStorage.removeItem('next_url')
  alert "次スタートする時に自動で開くURLを削除しました"
  $('.next_url_cancel').fadeOut()

window.finish = () ->
  console.log 'finish'
  location.reload()

window.comment = (body) ->
  console.log 'comment'
  return if body.length < 1
  return if window.is_commenting
  window.is_commenting = true
  params = {body: body}
  for key in ['sc_id']
    params[key] = localStorage[key]

  ParseParse.create('Comment', params, ()->
    window.is_commenting = false
    initComments()
  )

ruffnote = (id, dom) ->
  Ruffnote.fetch("pandeiro245/245cloud/#{id}", dom)