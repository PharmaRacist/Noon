import argparse
import json
import random
import sys

from ytmusicapi import YTMusic


def extract_thumbnail(item):
    thumbs = item.get("thumbnails")
    if isinstance(thumbs, list) and thumbs:
        url = thumbs[-1].get("url", "")
        if url:
            return url

    thumb = item.get("thumbnail")
    if isinstance(thumb, dict):
        nested = thumb.get("thumbnails", [])
        if nested:
            url = nested[-1].get("url", "")
            if url:
                return url

    video_id = item.get("videoId")
    if video_id:
        return f"https://i.ytimg.com/vi/{video_id}/sddefault.jpg"

    return ""


def build_track(item, via):
    title = item.get("title", "Unknown")
    video_id = item.get("videoId")
    artists = item.get("artists") or []
    artist = artists[0].get("name", "Unknown") if artists else "Unknown"
    url = f"https://music.youtube.com/watch?v={video_id}" if video_id else ""
    return {
        "title": title,
        "artist": artist,
        "url": url,
        "thumbnail": extract_thumbnail(item),
        "via": via,
    }


def cmd_search(args):
    yt = YTMusic()
    results = yt.search(args.query, filter="songs", limit=args.limit)
    tracks = [build_track(item, via="search") for item in results[: args.limit]]
    print(json.dumps(tracks, indent=2, ensure_ascii=False))


def cmd_recommend(args):
    with open(args.file, "r", encoding="utf-8") as f:
        library = json.load(f)

    local_tracks = {
        f"{item.get('artist', '')} - {item.get('title', '')}".strip().lower()
        for item in library.values()
    }
    seen = set(local_tracks)

    yt = YTMusic()
    track_list = list(local_tracks)
    num_seeds = max(3, args.limit // 4)
    seeds = random.sample(track_list, min(len(track_list), num_seeds))

    recommendations = []

    for seed in seeds:
        if len(recommendations) >= args.limit:
            break
        try:
            search = yt.search(seed, filter="songs")
            if not search:
                continue
            video_id = search[0].get("videoId")
            if not video_id:
                continue
            playlist = yt.get_watch_playlist(videoId=video_id, limit=15)
            for item in playlist.get("tracks", []):
                if len(recommendations) >= args.limit:
                    break
                track = build_track(item, via=seed)
                key = f"{track['artist']} - {track['title']}".lower()
                if not item.get("videoId") or key in seen:
                    continue
                seen.add(key)
                recommendations.append(track)
        except Exception:
            continue

    random.shuffle(recommendations)
    print(json.dumps(recommendations[: args.limit], indent=2, ensure_ascii=False))


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    p_search = sub.add_parser("search")
    p_search.add_argument("--query", required=True)
    p_search.add_argument("--limit", type=int, default=20)

    p_recommend = sub.add_parser("recommend")
    p_recommend.add_argument("file")
    p_recommend.add_argument("--limit", type=int, default=20)

    args = parser.parse_args()

    try:
        if args.command == "search":
            cmd_search(args)
        elif args.command == "recommend":
            cmd_recommend(args)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
