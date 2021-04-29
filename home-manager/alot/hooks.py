from datetime import datetime, timedelta

def timestamp_format(d):
    hourminfmt = '%H:%M'

    now = datetime.now()
    today = now.date()
    if d.date() == today or d > now - timedelta(hours=6):
        delta = datetime.now() - d
        if delta.seconds < 60:
            string = 'just now'
        elif delta.seconds < 3600:
            string = '%dmin ago' % (delta.seconds // 60)
        elif delta.seconds < 6 * 3600:
            string = '%dh ago' % (delta.seconds // 3600)
        else:
            string = d.strftime('tod ' + hourminfmt)
    elif d.date() == today - timedelta(1):
        string = d.strftime('yst ' + hourminfmt)
    elif d.date() > today - timedelta(7):
        string = d.strftime('%a ' + hourminfmt)
    elif d.year != today.year:
        string = d.strftime('%b %Y')
    else:
        string = d.strftime('%b %d')
    return string
