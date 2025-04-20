package;

import haxe.io.Bytes;
import haxe.io.Path;
import lime.utils.AssetBundle;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

#if disable_preloader_assets
@:dox(hide) class ManifestResources {
	public static var preloadLibraries:Array<Dynamic>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;

	public static function init (config:Dynamic):Void {
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
	}
}
#else
@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

			if(!StringTools.endsWith (rootPath, "/")) {

				rootPath += "/";

			}

		}

		if (rootPath == null) {

			#if (ios || tvos || webassembly)
			rootPath = "assets/";
			#elseif android
			rootPath = "";
			#elseif (console || sys)
			rootPath = lime.system.System.applicationDirectory;
			#else
			rootPath = "./";
			#end

		}

		#if (openfl && !flash && !display)
		openfl.text.Font.registerFont (__ASSET__OPENFL__file_assets_ui_otf);
		openfl.text.Font.registerFont (__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf);
		openfl.text.Font.registerFont (__ASSET__OPENFL__flixel_fonts_monsterrat_ttf);
		
		#end

		var data, manifest, library, bundle;

		Assets.libraryPaths["default"] = rootPath + "manifest/default.json";
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

	}


}

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_breath_1_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_breath_2__wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_breath_3__wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breath_1_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breath_2_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breath_3_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_a_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ba_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_be_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_bi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_bo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_bu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_chi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_da_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_de_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_di_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_do_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_du_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_e_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_fu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ga_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ge_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_gi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_go_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_gu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ha_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_he_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_hi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_hu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_i_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ji_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ka_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ke_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ki_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ko_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ku_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ma_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_me_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_mi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_mo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_mu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_n_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_na_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ne_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ni_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_no_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_nu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_o_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_pa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_pe_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_pi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_po_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_pu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ra_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_re_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ri_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ro_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ru_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_sa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_se_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_shi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_so_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_su_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ta_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_te_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_to_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_tsu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_u_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_wa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_wo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ya_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_yo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_yu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_za_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_ze_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_zi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_zo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_breaths_zu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_config_ini extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_a_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ba_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_be_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_bi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_bo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_bu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_chi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_da_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_de_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_di_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_do_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_du_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_e_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_fu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ga_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ge_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_gi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_go_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_gu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ha_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_he_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_hi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ho_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_hu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_i_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ji_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ju_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ka_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ke_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ki_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ko_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ku_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ma_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_me_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_mi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_mo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_mu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_n_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_na_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ne_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ni_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_no_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_nu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_o_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_pa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_pe_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_pi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_po_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_pu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ra_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_re_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ri_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ro_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ru_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_sa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_se_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_shi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_so_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_su_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ta_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_te_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_to_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_tsu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_u_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_wa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_wo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ya_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_yo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_yu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_za_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_ze_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_zi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_zo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_normal_zu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_a_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ba_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_be_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_bi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_bo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_bu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_chi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_de_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_do_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_du_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_e_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_fu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ga_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ge_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_gi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_go_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_gu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ha_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_he_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_hi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ho_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_hu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_i_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ji_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ka_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ke_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ki_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ko_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ku_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ma_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_me_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_mi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_mo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_mu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_n_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_na_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ne_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ni_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_no_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_nu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_o_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_pa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_pe_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_pi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_po_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_pu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ra_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_re_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ro_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ru_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_sa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_se_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_shi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_so_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_su_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ta_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_te_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_to_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_tsu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_u_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_wa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_wo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_ya_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_yo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_yu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_za_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_zi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_power_zu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_a_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ba_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_be_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_bi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_bo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_bu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_chi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_da_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_de_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_di_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_do_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_du_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_e_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_fu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ga_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ge_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_gi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_go_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_gu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ha_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_he_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_hi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ho_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_hu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_i_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ji_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ka_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ke_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ki_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ku_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ma_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_me_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_mi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_mo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_mu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_n_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_na_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ne_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ni_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_no_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_nu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_o_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_pa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_pe_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_pi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_po_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_pu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ra_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_re_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ri_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ro_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ru_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_sa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_se_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_shi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_so_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_su_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ta_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_te_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_to_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_tsu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_u_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_wa_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_wo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ya_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_yo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_yu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_za_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_ze_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_zi_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_zo_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_soft_zu_wav extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__voicebanks_kasane_teto_lite_teto_svp extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__file_assets_cursor_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__file_assets_startup_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__file_assets_ui_0_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__file_assets_ui_1_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__file_assets_ui_2_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__file_assets_ui_3_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__file_assets_ui_otf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_sounds_beep_ogg extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_sounds_flixel_ogg extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_ui_button_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_logo_default_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_circle_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diagonal_gradient_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diamond_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_square_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_box_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_arrow_down_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_arrow_left_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_arrow_right_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_arrow_up_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_thin_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_toggle_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_check_box_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_check_mark_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_chrome_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_chrome_flat_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_chrome_inset_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_chrome_light_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_dropdown_mark_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_finger_big_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_finger_small_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_hilight_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_invis_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_minus_mark_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_plus_mark_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_radio_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_radio_dot_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_swatch_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_tab_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_tab_back_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_tooltip_arrow_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_xml_defaults_xml extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_xml_default_loading_screen_xml extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_xml_default_popup_xml extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:image("_assets/cursor.png") @:noCompletion #if display private #end class __ASSET__file_assets_cursor_png extends lime.graphics.Image {}
@:keep @:image("_assets/startup.png") @:noCompletion #if display private #end class __ASSET__file_assets_startup_png extends lime.graphics.Image {}
@:keep @:image("_assets/UI-0.png") @:noCompletion #if display private #end class __ASSET__file_assets_ui_0_png extends lime.graphics.Image {}
@:keep @:image("_assets/UI-1.png") @:noCompletion #if display private #end class __ASSET__file_assets_ui_1_png extends lime.graphics.Image {}
@:keep @:image("_assets/UI-2.png") @:noCompletion #if display private #end class __ASSET__file_assets_ui_2_png extends lime.graphics.Image {}
@:keep @:image("_assets/UI-3.png") @:noCompletion #if display private #end class __ASSET__file_assets_ui_3_png extends lime.graphics.Image {}
@:keep @:font("_assets/ui.otf") @:noCompletion #if display private #end class __ASSET__file_assets_ui_otf extends lime.text.Font {}
@:keep @:file("C:/haxelib/flixel/6,0,0/assets/sounds/beep.ogg") @:noCompletion #if display private #end class __ASSET__flixel_sounds_beep_ogg extends haxe.io.Bytes {}
@:keep @:file("C:/haxelib/flixel/6,0,0/assets/sounds/flixel.ogg") @:noCompletion #if display private #end class __ASSET__flixel_sounds_flixel_ogg extends haxe.io.Bytes {}
@:keep @:font("C:/haxelib/flixel/6,0,0/assets/fonts/nokiafc22.ttf") @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends lime.text.Font {}
@:keep @:font("C:/haxelib/flixel/6,0,0/assets/fonts/monsterrat.ttf") @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends lime.text.Font {}
@:keep @:image("C:/haxelib/flixel/6,0,0/assets/images/ui/button.png") @:noCompletion #if display private #end class __ASSET__flixel_images_ui_button_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel/6,0,0/assets/images/logo/default.png") @:noCompletion #if display private #end class __ASSET__flixel_images_logo_default_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-addons/3,3,2/assets/images/transitions/circle.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_circle_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-addons/3,3,2/assets/images/transitions/diagonal_gradient.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diagonal_gradient_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-addons/3,3,2/assets/images/transitions/diamond.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diamond_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-addons/3,3,2/assets/images/transitions/square.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_square_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/box.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_box_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/button.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/button_arrow_down.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_arrow_down_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/button_arrow_left.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_arrow_left_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/button_arrow_right.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_arrow_right_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/button_arrow_up.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_arrow_up_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/button_thin.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_thin_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/button_toggle.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_button_toggle_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/check_box.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_check_box_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/check_mark.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_check_mark_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/chrome.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_chrome_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/chrome_flat.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_chrome_flat_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/chrome_inset.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_chrome_inset_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/chrome_light.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_chrome_light_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/dropdown_mark.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_dropdown_mark_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/finger_big.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_finger_big_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/finger_small.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_finger_small_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/hilight.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_hilight_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/invis.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_invis_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/minus_mark.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_minus_mark_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/plus_mark.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_plus_mark_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/radio.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_radio_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/radio_dot.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_radio_dot_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/swatch.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_swatch_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/tab.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_tab_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/tab_back.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_tab_back_png extends lime.graphics.Image {}
@:keep @:image("C:/haxelib/flixel-ui/2,6,4/assets/images/tooltip_arrow.png") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_img_tooltip_arrow_png extends lime.graphics.Image {}
@:keep @:file("C:/haxelib/flixel-ui/2,6,4/assets/xml/defaults.xml") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_xml_defaults_xml extends haxe.io.Bytes {}
@:keep @:file("C:/haxelib/flixel-ui/2,6,4/assets/xml/default_loading_screen.xml") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_xml_default_loading_screen_xml extends haxe.io.Bytes {}
@:keep @:file("C:/haxelib/flixel-ui/2,6,4/assets/xml/default_popup.xml") @:noCompletion #if display private #end class __ASSET__flixel_flixel_ui_xml_default_popup_xml extends haxe.io.Bytes {}



#else

@:keep @:expose('__ASSET__file_assets_ui_otf') @:noCompletion #if display private #end class __ASSET__file_assets_ui_otf extends lime.text.Font { public function new () { #if !html5 __fontPath = "_assets/ui.otf"; #else ascender = null; descender = null; height = null; numGlyphs = null; underlinePosition = null; underlineThickness = null; unitsPerEM = null; #end name = "Xirod-Regular"; super (); }}
@:keep @:expose('__ASSET__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "flixel/fonts/nokiafc22.ttf"; #else ascender = null; descender = null; height = null; numGlyphs = null; underlinePosition = null; underlineThickness = null; unitsPerEM = null; #end name = "Nokia Cellphone FC Small"; super (); }}
@:keep @:expose('__ASSET__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "flixel/fonts/monsterrat.ttf"; #else ascender = null; descender = null; height = null; numGlyphs = null; underlinePosition = null; underlineThickness = null; unitsPerEM = null; #end name = "Monsterrat"; super (); }}


#end

#if (openfl && !flash)

#if html5
@:keep @:expose('__ASSET__OPENFL__file_assets_ui_otf') @:noCompletion #if display private #end class __ASSET__OPENFL__file_assets_ui_otf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__file_assets_ui_otf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_nokiafc22_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_nokiafc22_ttf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_monsterrat_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_monsterrat_ttf ()); super (); }}

#else
@:keep @:expose('__ASSET__OPENFL__file_assets_ui_otf') @:noCompletion #if display private #end class __ASSET__OPENFL__file_assets_ui_otf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__file_assets_ui_otf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_nokiafc22_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_nokiafc22_ttf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_monsterrat_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_monsterrat_ttf ()); super (); }}

#end

#end
#end

#end