//------------------------------------------------------------------------------
// <auto-generated>
//     Este código se generó a partir de una plantilla.
//
//     Los cambios manuales en este archivo pueden causar un comportamiento inesperado de la aplicación.
//     Los cambios manuales en este archivo se sobrescribirán si se regenera el código.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Opiniometro_WebApp.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Item
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Item()
        {
            this.Conformado_Item_Sec_Form = new HashSet<Conformado_Item_Sec_Form>();
            this.Responde = new HashSet<Responde>();
        }
    
        public string ItemId { get; set; }
        public string TextoPregunta { get; set; }
        public Nullable<bool> TieneObservacion { get; set; }
        public byte TipoPregunta { get; set; }
        public string NombreCategoria { get; set; }
        public string EtiquetaObservacion { get; set; }
    
        public virtual Categoria Categoria { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Conformado_Item_Sec_Form> Conformado_Item_Sec_Form { get; set; }
        public virtual Escalar Escalar { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Responde> Responde { get; set; }
        public virtual Seleccion_Multiple Seleccion_Multiple { get; set; }
        public virtual Seleccion_Unica Seleccion_Unica { get; set; }
        public virtual Texto_Libre Texto_Libre { get; set; }
    }
}
