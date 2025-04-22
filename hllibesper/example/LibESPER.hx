package;

import hl.F32;

@:hlNative("libesper")
class LibESPER
{
    public static function resample_samples(
        sampleRate:Int,
        samples:Array<F32>,
        sampleLen:Int, 
        pitchSemitones:F32, 
        formantShift:F32, 
        breathiness:F32
    ):Array<F32>
        return [];  // This should not be getting returned. It should be calling/returning the native function.
    
	public static function processSamples(
        sampleRate:Int,
        input:Array<Float>,
        semitones:Float,
        formantShift:Float,
        breathiness:Float
    ):Array<Float> {

        var f32Array:Array<F32> = [];
        for (i in 0...input.length)
            f32Array[i] = input[i];
        
        // Call the native function
        var result = resample_samples(
            sampleRate,
            f32Array,
            input.length * 4,
            semitones,
            formantShift,
            breathiness
        );

        var finalRes:Array<Float> = [];
        for (i in 0...result.length)
            finalRes[i] = result[i];
        
        return finalRes;
    }
}
