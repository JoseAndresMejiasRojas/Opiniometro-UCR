//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Opiniometro_WebApp.Models
{
    using System;
    using System.Collections.Generic;
    
    public partial class Seleccion_Multiple
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Seleccion_Multiple()
        {
            this.Opciones_De_Respuestas_Seleccion_Multiple = new HashSet<Opciones_De_Respuestas_Seleccion_Multiple>();
        }
    
        public string ItemId { get; set; }
    
        public virtual Item Item { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Opciones_De_Respuestas_Seleccion_Multiple> Opciones_De_Respuestas_Seleccion_Multiple { get; set; }
    }
}