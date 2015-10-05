fs      = require 'fs'
_       = require 'lodash'
Nt      = require './noitech.coffee'
gen     = Nt.generate
eff     = Nt.effect
cp      = require 'child_process'
say     = require './say.coffee'

ramp = 60

module.exports = (s, p, voices, lines, times, timings, voiceCount) ->

  _.times voiceCount, (vi) -> 

    forThisPart   = (b) -> b.slice (48 * p) + 8, (48 * (p + 1)) + 8
    if p is 0 
      forThisPart = (b) -> b.slice (48 * p), (48 * (p + 1)) + 8

    melody = forThisPart s[       vi ]
    timing = forThisPart timings[ vi ]
    time   = forThisPart times[   vi ]
    timing = _.map timing, (t) -> t - timing[0]
    time   = _.map time,   (t) -> t - time[0]
    voice  = voices[  vi ] 
    line   = lines[   vi ]

    _.forEach melody, (note, ni) ->

      thisTime = time[ ni ]    
      nextTime = time[ ni + 1 ]

      if note isnt ''

        if note is 'Q'

          durationOfNote = sustain: (44100 * 4)
          blockOfSilence = gen.silence durationOfNote
          blockOfLine    = line.slice thisTime - ramp, nextTime
          blockOfSilence = blockOfLine.concat blockOfSilence
          blockOfSilence = eff.fadeOut blockOfSilence, 
            (beginAt: 0, endAt: ramp)

          line = Nt.displace blockOfSilence, line, thisTime - ramp

        else

          if voice[ note ] is undefined
            say 'Error. Voice lacks note ' + note
            console.log note, vi, ni

          else

            line = Nt.mix voice[ note ], line, thisTime

    lines[ vi ] = line

  lines


