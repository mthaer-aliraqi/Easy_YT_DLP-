#!/bin/bash

install_tool(){
    # check if tool not installed , then install
    if ! command -v "$1" >/dev/null; then
        echo "$1 is not installed !"
        echo "installation begins."
        sleep 1
        sudo apt "$1" 2>/dev/null
        sudo dnf "$1" 2>/dev/null
        sudo pacman -S "$1" 2>/dev/null
        sleep 2
    fi
}

quick_fix(){
    #if anu tool not exist install it
    tool="python"
    install_tool $tool
    tool="python3"
    install_tool $tool
    tool="deno"
    install_tool $tool
    tool="ffmpeg"
    install_tool $tool
    
    # run python from .venv
    source ~/.venv/bin/activate
    sleep 1

    # install youtube-downloader if not existed
    if ! command -v "yt-dlp" >/dev/null ; then
        pip install "yt-dlp[default]" 
        count=0
        while ! command -v "yt-dlp"; do
            sleep 0.5
            count=$((count++))
            if [ "$count" -gt 120 ];then
                echo "Error: time out !"
                echo "process tooke to long time and yet not done !"
                echo "check your internet connection it could be the issue."
                exit 1
            fi

            # if app installed
            if [ command -v "yt-dlp" ] >dev/null; then 
                echo "app installed successfully run the script again"
                exit 0
            fi
        done
    fi

    echo "fix has done"

    for counter in 5 4 3 2 1; do
        echo "reStarting in $counter..."
        sleep 1
    done

    # relaunch the code first "$0" is the script i am running now [ exec ] means replace it with the secon "$0" the same script with no variables  
    exec "$0" "$0"
}

python_maintance(){
    
    # if python script faced an issue
    if ! "$@" 2>/tmp/err-python-ytdlp.txt ;then
        echo "Error caused by python script !"
        echo "type [y] to apply quick-fix , or [n] to read error and fix it manually:"
        read answer
        
        echo
        
        if [ "$answer" = "y" ];then
            quick_fix
        else
            echo "steps can be used to fix your issue:"
            echo "1) make sure [python3 , deno , python , ffmpeg] are installed"
            echo "2) make sure the lib installed into .venv dir ,"
            echo "you can do that by running ( source .venv/bin/activate )"
            echo "then run ( pip install --upgrade yt-dlp ) this will install the lib into .venv/"
            echo "if you already installed it there then just run ( source .venv/bin/activate ) and retry again"
            exit 1
        fi
        
    fi

}

is_quality_valid(){
    case "$1" in
        144|240|360|480|720|1080)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

video(){
    echo

    echo "4) choose video quality (144 - 1080)"
    read video_quality

    echo ""

    # when video_quality is not valid
    while ! is_quality_valid "$video_quality"; do
        echo "Error: video_quality is not valid !"
        echo "supported relosutions [144|240|360|480|720|1080]"
        sleep 2
        echo
        echo "4) choose video quality (144 - 1080)"
        read video_quality
    done

    # download as video
    python_maintance yt-dlp -f "bestvideo[height<=$video_quality]+bestaudio/best[height<=$video_quality]" --merge-output-format mp4 -o "$2/%(title)s.%(ext)s" "$1"   ;

}

is_audio_quality_valid(){
    case "$1" in
    20|30|35|45|55|75|100|130|170|190|245) 
        return 0 ;;
    *)  
        return 1 ;;
    esac
}

audio(){
    echo

    echo "4) choose audio quality VBR [20|30|35|45|55|75|100|130|170|190|245] kbps"
    read audio_quality

    echo

    #when audio quality is not valid
    while ! is_audio_quality_valid "$audio_quality"; do
        echo "Error: auio-quality is not valid !"
        echo "supported qualities [20|30|35|45|55|75|100|130|170|190|245]"
        sleep 2
        echo
        echo "4) choose audio quality VBR (20 - 245) kbps"
        read audio_quality
    done

    # convert to indexpython recieve
    case "$audio_quality" in
        20)
            audio_q=10
            ;;
        30)
            audio_q=9
            ;;
        35)
            audio_q=8
            ;;
        45)
            audio_q=7
            ;;
        55)
            audio_q=6
            ;;
        75)
            audio_q=5
            ;;
        100)
            audio_q=4
            ;;
        130)
            audio_q=3
            ;;
        170)
            audio_q=2
            ;;
        190)
            audio_q=1
            ;;
        245) 
            audio_q=0
            ;;
        *)
            audio_q=0
            ;;
    esac

    # download as audio
    python_maintance yt-dlp -x --audio-format mp3 --audio-quality "$audio_q" -o "$2/%(title)s.%(ext)s" "$1"   
}



echo "welcome to youtube-video/audio-downloader with python "
echo "this script suppose to make the tool [ yt-dlp ] (youtube downloader) simpler easier to use."
echo "make sure to follow instructions properly"
echo
echo "--------------------------------------------------"
echo "🚨 warning: this tool is safe and the script works but if they caused any damage to your device,"
echo "🚨 i am not responsible about any hardware or software damage or issues."
echo "🚨 you use it at your own risk"
echo "🚨 I bear no responsibility for any misuse of this tool, including downloading restricted content, copyrighted music, or causing harm to others."
echo "--------------------------------------------------"
echo

sleep 1

echo "1) paste your link with ctrl+shift+v"
read -r link

#if link is not valid
while ! echo "$link" | grep -q "http" ; do
    echo "Error: link is not valid !"
    sleep 2
    echo
    echo "1) paste your link with ctrl+shift+v"
    read -r link
done

echo

sleep 1

echo "2) save media file to path: "
read output_path

# if path not valid or ends with /
while echo "$output_path" | grep -q "/$"; do
    echo "Error: path is not valid !"
    echo "path shouldn't end with / "
    sleep 2
    echo
    echo "2) save media file to path: "
    read output_path
done

echo

sleep 1

echo "3) choose media type type 1 for video , 2 for audio"
read mediaType

# input is not 1 or 2
# command1 || command2 , means if command 1 failed run command 2
# command1 && command2 , means if command 1 success run command 2
while [ ! "$mediaType" -eq 1 ] && [ ! "$mediaType" -eq 2 ]; do
    echo "Error: media type is not valid !"
    sleep 2
    echo
    echo "3) choose media type type 1 for video , 2 for audio"
    read mediaType
done

sleep 1

if [ "$mediaType" -eq 1 ];then
    video "$link" "$output_path"
else
    audio "$link" "$output_path"
fi



# yt-dlp -f "bestvideo[height<=720]+bestaudio/best[height<=720]" --merge-output-format mp4 -o "~/Desktop/%(title)s.%(ext)s" "https://youtu.be/AqVozqOZX7Q"   ;
