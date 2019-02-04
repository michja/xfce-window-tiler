#! /bin/bash

if [ $# -ne 2 ]; then
  echo "need two args T/B L/R"
  exit 1
fi

X=$2
Y=$1

WIN_ID=$(xdotool getactivewindow)

# calculates the new window position
# --- returns 
# --- read -r TARGET_X TARGET_Y TARGET_W TARGET_H <<<$(targetWindowGeometry $X $Y)
targetWindowGeometry() {
  # get screen dimensions
  SCREEN_X=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d "x" -f1)
  SCREEN_Y=$(xdpyinfo | awk '/dimensions/{print $2}' | cut -d "x" -f2)
  # respect XFCE margins
  MARGIN_L=$(xfconf-query -c xfwm4 -p /general/margin_left)
  MARGIN_R=$(xfconf-query -c xfwm4 -p /general/margin_right)
  MARGIN_T=$(xfconf-query -c xfwm4 -p /general/margin_top)
  MARGIN_B=$(xfconf-query -c xfwm4 -p /general/margin_bottom)
  # calc usable screen space
  Y_MOD=4 # modifiers needed for unknown reason
  X_MOD=4 # to fit the actual space
  USABLE_X=$(($SCREEN_X-$MARGIN_L-$MARGIN_R-$X_MOD))
  USABLE_Y=$(($SCREEN_Y-$MARGIN_T-$MARGIN_B-$Y_MOD))
  INNER_MARGIN_X=10
  INNER_MARGIN_Y=10
  # target geometry
  # w h
  TARGET_W=$USABLE_X
  if [ $1 != "M" ]; then TARGET_W=$((($TARGET_W-$INNER_MARGIN_X)/2)); fi
  TARGET_H=$USABLE_Y
  if [ $2 != "M" ]; then TARGET_H=$((($TARGET_H-$INNER_MARGIN_Y)/2)); fi
  # x y
  declare -A X
  X[L]=$MARGIN_L
  X[M]=$MARGIN_L
  X[R]=$(($MARGIN_L+$TARGET_W+$INNER_MARGIN_X))
  declare -A Y
  Y[T]=$MARGIN_T
  Y[M]=$MARGIN_T
  Y[B]=$(($MARGIN_T+$TARGET_H+$INNER_MARGIN_Y))
  TARGET_X=${X[$1]}
  TARGET_Y=${Y[$2]}
  echo "$TARGET_X $TARGET_Y $TARGET_W $TARGET_H"
}

# get starting geometry from window id
# --- returns 
# --- read -r START_X START_Y START_W START_H <<<$(getWindowGeometry $WIN_ID)
getWindowGeometry() {
  declare -a RESULT
  eval $(xwininfo -id $1 |
    sed -n -e "s/^ \+Absolute upper-left X: \+\([0-9]\+\).*/ABS_X=\1/p" \
           -e "s/^ \+Absolute upper-left Y: \+\([0-9]\+\).*/ABS_Y=\" \"\1/p" \
           -e "s/^ \+Relative upper-left X: \+\([0-9]\+\).*/REL_X=\1/p" \
           -e "s/^ \+Relative upper-left Y: \+\([0-9]\+\).*/REL_Y=\1/p" \
           -e "s/^ \+Width: \+\([0-9]\+\).*/WIN_W=\" \"\1/p" \
           -e "s/^ \+Height: \+\([0-9]\+\).*/WIN_H+=\" \"\1/p" )
  WIN_X=$(($ABS_X-$REL_X))
  WIN_Y=$(($ABS_Y-$REL_Y))

  echo "$WIN_X $WIN_Y $WIN_W $WIN_H"
  # echo ${RESULT[@]}
}

# move a window using xdotools
xdothemove() {
  xdotool windowmove $1 $2 $3
  xdotool windowsize $1 $4 $5
}

# https://github.com/b3nson/sh.ease
source $HOME/.scripts/easing.sh

easemovewindow() {
  WIN_ID=$1
  X=$2
  Y=$3
  read -r TARGET_X TARGET_Y TARGET_W TARGET_H <<<$(targetWindowGeometry $X $Y)
  read -r START_X START_Y START_W START_H <<<$(getWindowGeometry $WIN_ID)
  # calc move deltas
  DELTA_X=$(($TARGET_X-$START_X))
  DELTA_Y=$(($TARGET_Y-$START_Y))
  DELTA_W=$(($TARGET_W-$START_W))
  DELTA_H=$(($TARGET_H-$START_H))

  # do the move
  for i in {0..14}
  do
    x=`quad_easeInOut $i $START_X $DELTA_X 14`
    y=`quad_easeInOut $i $START_Y $DELTA_Y 14`
    # final height will bug out if left to animate until the last loop
    # so stop early. plus the animation looks a little nicer
    if [ $i -lt 10 ]; then
      w=`quad_easeInOut $i $START_W $DELTA_W 10`
      h=`quad_easeInOut $i $START_H $DELTA_H 10`
    else
      w=$TARGET_W
      h=$TARGET_H
    fi      
    # echo "Start $START_X x $START_Y"
    # echo "Targets $TARGET_X x $TARGET_Y"
    # echo $x $y
    xdothemove $WIN_ID $x $y $w $h
  done
  
  # one more move to confirm we are in the right spot
  xdothemove $WIN_ID $TARGET_X $TARGET_Y $TARGET_W $TARGET_H
}


easemovewindow $WIN_ID $X $Y
