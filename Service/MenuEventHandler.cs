﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Castle.Core.Logging;
using SAPbouiCOM;
using AddOne.Framework.Attribute;
using AddOne.Framework.Factory;
using SAPbouiCOM.Framework;

namespace AddOne.Framework.Service
{
    class MenuEventHandler
    {
        public ILogger Logger { get; set; }
        Dictionary<string, List<MenuEventAttribute>> menuEvents = new Dictionary<string, List<MenuEventAttribute>>();

        public MenuEventHandler()
        {
        }

        internal void sapApp_MenuEvent(ref MenuEvent pVal, out bool BubbleEvent)
        {
            BubbleEvent = true;

            List<MenuEventAttribute> events;
            menuEvents.TryGetValue(pVal.MenuUID, out events);

            if (events != null)
            {
                foreach (var e in events)
                {
                    DispatchForm(e.OriginalType, ref pVal, out BubbleEvent);
                }
            }
        }

        private void DispatchForm(Type type, ref MenuEvent pVal, out bool BubbleEvent)
        {
            BubbleEvent = true;

            // Prevent event from running twice.
            if (!pVal.BeforeAction)
                return;

            try
            {
                var obj = ContainerManager.Container.Resolve(type);
                if (obj is FormBase)
                {
                    Logger.Debug(String.Format(Messages.MenuDispatchInfo, pVal.MenuUID, type));
                    var method = type.GetMethod("Show");
                    method.Invoke(obj, null);
                }
                else if (type.DeclaringMethod != null)
                {
                    Logger.Debug(String.Format(Messages.MenuDispatchInfo, pVal.MenuUID, type));
                    type.DeclaringMethod.Invoke(obj, null);
                }
                else
                {
                    Logger.Debug(string.Format(Messages.FileMissing, type, "?"));
                }
            }
            catch (Exception e)
            {
                Logger.Error(String.Format(Messages.MenuDispatchError, pVal.MenuUID, e.Message), e);
            }
        }


        internal void RegisterMenuEvent(MenuEventAttribute menuEventAttribute)
        {
            List<MenuEventAttribute> events;
            Logger.Debug(String.Format(Messages.RegisteringMenuEvent, menuEventAttribute.UniqueUID, menuEventAttribute.OriginalType));
            menuEvents.TryGetValue(menuEventAttribute.UniqueUID, out events);
            if (events == null)
            {
                events = new List<MenuEventAttribute>();
                menuEvents.Add(menuEventAttribute.UniqueUID, events);
            }

            if (!events.Contains(menuEventAttribute))
                events.Add(menuEventAttribute);

        }
    }
}