show_views_files = sc.textFile("input/join2_gennum?.txt")
def split_show_channel(line):
    show, channel = line.split(",")
    return (show, channel)

show_views = show_views_files.map(split_show_views)

def split_show_views(line):
    show, views = line.split(",")
    return (show, views)

show_channel_files = sc.textFile("input/join2_genchan?.txt")
show_channel = show_channel_files.map(split_show_channel)
joined_dataset = show_views.join(show_channel)

def extract_channel_views(show_views_channel):
    show, righ = show_views_channel.split(",")
    views,channel = righ[0], righ[1]
    return (channel, int(views))

def sum_fun(a,b):
    return a+b

channel_views = joined_dataset.map(extract_channel_views)
chan = channel_views.reduceByKey(sum_fun)
chan.collect()
